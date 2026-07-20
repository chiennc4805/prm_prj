const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

async function errorOf(response) {
  let message = `Lỗi máy chủ (${response.status})`;
  try {
    const data = await response.json();
    message = data.message || data.detail || message;
  } catch {}
  return new Error(message);
}
async function request(path, options = {}) {
  const response = await fetch(`${API_URL}${path}`, {
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
    ...options,
  });
  if (!response.ok) throw await errorOf(response);
  if (response.status === 204) return null;
  return response.json();
}
async function upload(path, file) {
  const body = new FormData();
  body.append('file', file);
  const response = await fetch(`${API_URL}${path}`, { method: 'POST', body });
  if (!response.ok) throw await errorOf(response);
  return response.json();
}
async function download(path, filename) {
  const response = await fetch(`${API_URL}${path}`);
  if (!response.ok) throw await errorOf(response);
  const url = URL.createObjectURL(await response.blob());
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
}
export const api = {
  get: (path) => request(path),
  post: (path, body) => request(path, { method: 'POST', body: JSON.stringify(body) }),
  put: (path, body) => request(path, { method: 'PUT', body: JSON.stringify(body) }),
  delete: (path) => request(path, { method: 'DELETE' }),
  upload,
  download,
};
