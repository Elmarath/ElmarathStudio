import React from 'react';
import { createPortal } from 'react-dom';
import styles from './ResumeModal.module.css';

/**
 * ResumeModal Component - Displays PDF resume with download option
 */
const ResumeModal = ({ isOpen, onClose }) => {
    if (!isOpen) return null;

    const handleDownload = () => {
        const link = document.createElement('a');
        link.href = '/docs/DenizhanToprak_Resume.pdf';
        link.download = 'DenizhanToprak_Resume.pdf';
        link.click();
    };

    const handleBackdropClick = (e) => {
        if (e.target === e.currentTarget) {
            onClose();
        }
    };

    return createPortal(
        <div className={styles.modalOverlay} onClick={handleBackdropClick}>
            <div className={styles.resumeModal} onClick={(e) => e.stopPropagation()}>
                <div className={styles.modalHeader}>
                    <h2>Denizhan Toprak - Resume</h2>
                    <div className={styles.modalActions}>
                        <button 
                            className={styles.downloadButton}
                            onClick={handleDownload}
                        >
                            Download PDF
                        </button>
                        <button 
                            className={styles.closeButton}
                            onClick={onClose}
                        >
                            ✕
                        </button>
                    </div>
                </div>
                <div className={styles.pdfContainer}>
                    <iframe
                        src="/docs/DenizhanToprak_Resume.pdf"
                        className={styles.pdfViewer}
                        title="Resume PDF"
                    />
                </div>
            </div>
        </div>,
        document.body
    );
};

export default ResumeModal;