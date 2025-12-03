import React from 'react';
import { createPortal } from 'react-dom';
import styles from './PDFViewer.module.css';

/**
 * PDFViewer Component - Displays PDF in a modal
 * @param {boolean} isOpen - Modal open state
 * @param {function} onClose - Function to close modal
 * @param {string} pdfUrl - URL to the PDF file
 * @param {string} title - Title for the PDF viewer
 * @param {string} downloadFileName - Filename for download
 */
const PDFViewer = ({ isOpen, onClose, pdfUrl, title, downloadFileName }) => {
  if (!isOpen) return null;

  const handleDownload = () => {
    const link = document.createElement('a');
    link.href = pdfUrl;
    link.download = downloadFileName || 'document.pdf';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleShare = async () => {
    const fullUrl = `${window.location.origin}${pdfUrl}`;
    
    try {
      await navigator.clipboard.writeText(fullUrl);
      // Show temporary success feedback
      const button = document.querySelector(`.${styles.shareButton}`);
      if (button) {
        const originalText = button.textContent;
        button.textContent = '✅ Copied!';
        button.style.background = 'var(--ifm-color-success)';
        setTimeout(() => {
          button.textContent = originalText;
          button.style.background = '';
        }, 2000);
      }
    } catch (err) {
      // Fallback for older browsers
      const textArea = document.createElement('textarea');
      textArea.value = fullUrl;
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);
    }
  };

  return createPortal(
    <div className={styles.modalOverlay} onClick={onClose}>
      <div className={styles.pdfModal} onClick={(e) => e.stopPropagation()}>
        <div className={styles.header}>
          <h3>{title || 'PDF Viewer'}</h3>
          <div className={styles.headerActions}>
            <div className={styles.actionButtons}>
              <button
                className={styles.shareButton}
                onClick={handleShare}
                title="Copy shareable link"
              >
                🔗 Share
              </button>
              <button
                className={styles.downloadButton}
                onClick={handleDownload}
                title="Download PDF"
              >
                📥 Download
              </button>
            </div>
            <button
              className={styles.closeButton}
              onClick={onClose}
              title="Close"
            >
              ✕
            </button>
          </div>
        </div>
        
        <div className={styles.pdfContainer}>
          <iframe
            src={pdfUrl}
            width="100%"
            height="100%"
            style={{ border: 'none' }}
            title={title}
          />
        </div>
      </div>
    </div>,
    document.body
  );
};

export default PDFViewer;