import re
import urllib.request
import urllib.parse
import http.cookiejar
from pathlib import Path

def extract_gdrive_id(url: str) -> str | None:
    if not url:
        return None
    # Support:
    # drive.google.com/file/d/ID/view...
    # drive.google.com/open?id=ID
    # drive.google.com/uc?id=ID&export=download
    # docs.google.com/file/d/ID...
    # raw ID if already 25+ chars
    m = re.search(r'(?:file/d/|id=|open\?id=|uc\?id=|file/u/\d+/d/)([a-zA-Z0-9_-]{20,})', url)
    if m:
        return m.group(1)
    if re.fullmatch(r'[a-zA-Z0-9_-]{25,}', url.strip()):
        return url.strip()
    return None

def is_gdrive_url(url: str) -> bool:
    if not url:
        return False
    u = url.lower()
    return ('drive.google.com' in u or 'docs.google.com' in u) and extract_gdrive_id(url) is not None

def download_gdrive(url_or_id: str, dest_path: Path, progress_hook=None):
    file_id = extract_gdrive_id(url_or_id)
    if not file_id:
        raise ValueError("Invalid Google Drive URL or File ID.")

    dest_path = Path(dest_path)
    dest_path.parent.mkdir(parents=True, exist_ok=True)

    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    headers = [
        ('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'),
        ('Accept', '*/*'),
        ('Accept-Language', 'en-US,en;q=0.9'),
    ]
    opener.addheaders = headers

    # Try standard Google Drive download entrypoints
    urls_to_try = [
        f"https://drive.usercontent.google.com/download?id={file_id}&export=download&confirm=t",
        f"https://drive.google.com/uc?export=download&id={file_id}&confirm=t",
        f"https://docs.google.com/uc?export=download&id={file_id}",
    ]

    resp = None
    for try_url in urls_to_try:
        try:
            req = urllib.request.Request(try_url)
            r = opener.open(req, timeout=30)
            ct = r.headers.get('Content-Type', '').lower()
            if 'text/html' not in ct:
                resp = r
                break
            else:
                html = r.read().decode('utf-8', errors='ignore')
                # Check for confirmation form (large file virus warning)
                form_match = re.search(r'<form\s+id="download-form"\s+action="([^"]+)"', html)
                confirm_match = re.search(r'confirm=([0-9A-Za-z_-]+)', html) or re.search(r'name="confirm"\s+value="([^"]+)"', html)

                if form_match:
                    action_url = form_match.group(1)
                    if not action_url.startswith('http'):
                        action_url = urllib.parse.urljoin(try_url, action_url)
                    inputs = dict(re.findall(r'<input\s+type="hidden"\s+name="([^"]+)"\s+value="([^"]*)"', html))
                    data = urllib.parse.urlencode(inputs).encode('utf-8')
                    post_req = urllib.request.Request(action_url, data=data)
                    r_post = opener.open(post_req, timeout=30)
                    if 'text/html' not in r_post.headers.get('Content-Type', '').lower():
                        resp = r_post
                        break
                elif confirm_match:
                    code = confirm_match.group(1)
                    alt_url = f"https://drive.usercontent.google.com/download?id={file_id}&export=download&confirm={code}"
                    r_alt = opener.open(urllib.request.Request(alt_url), timeout=30)
                    if 'text/html' not in r_alt.headers.get('Content-Type', '').lower():
                        resp = r_alt
                        break
        except Exception:
            continue

    if resp is None:
        raise RuntimeError("Google Drive video download nahi ho saka. Make sure video link share settings 'Anyone with the link can view' par set hai, ya fir video ko D: drive par download karke select karein.")

    total_size = int(resp.headers.get('Content-Length') or 0)
    downloaded = 0
    chunk_size = 512 * 1024  # 512 KB

    temp_path = dest_path.with_suffix('.gdrive.tmp')
    try:
        with open(temp_path, 'wb') as out_f:
            while True:
                chunk = resp.read(chunk_size)
                if not chunk:
                    break
                out_f.write(chunk)
                downloaded += len(chunk)
                if progress_hook:
                    progress_hook(downloaded, total_size)
        temp_path.replace(dest_path)
    finally:
        if temp_path.exists():
            try:
                temp_path.unlink()
            except Exception:
                pass

    return dest_path
