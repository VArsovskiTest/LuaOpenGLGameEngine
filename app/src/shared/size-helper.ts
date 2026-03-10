/**
 * Formats a size in bytes into a human-readable string (B, KB, MB, GB, TB).
 * @param {number} bytes - The size in bytes.
 * @returns {string} The formatted size string.
 */
export function formatSize(bytes: number) {
  if (bytes === 0) return '0 B';

  const sizeNames = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  let i = 0;
  let size = bytes;

  while (size >= 1024 && i < sizeNames.length - 1) {
    size /= 1024;
    i++;
  }

  return `${size.toFixed(2)} ${sizeNames[i]}`;
};
