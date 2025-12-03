import React from 'react';
import { createPortal } from 'react-dom';
import styles from './ResumeModal.module.css';

/**
 * ResumeModal Component - Displays PDF resume with download option
 */
const ResumeModal = ({ isOpen, onClose }) => {
    const [shareButtonText, setShareButtonText] = React.useState('Share');
    const [isShared, setIsShared] = React.useState(false);

    if (!isOpen) return null;

    const handleDownload = () => {
        const link = document.createElement('a');
        link.href = '/docs/DenizhanToprak_Resume.pdf';
        link.download = 'DenizhanToprak_Resume.pdf';
        link.click();
    };

    const handleShare = async () => {
        const pdfUrl = `${window.location.origin}/docs/DenizhanToprak_Resume.pdf`;
        
        try {
            await navigator.clipboard.writeText(pdfUrl);
            setShareButtonText('Copied!');
            setIsShared(true);
            setTimeout(() => {
                setShareButtonText('Share');
                setIsShared(false);
            }, 2000);
        } catch (err) {
            console.error('Failed to copy link: ', err);
            setShareButtonText('Failed');
            setIsShared(false);
            setTimeout(() => {
                setShareButtonText('Share');
                setIsShared(false);
            }, 2000);
        }
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
                            className={`${styles.shareButton} ${isShared ? styles.copied : ''}`}
                            onClick={handleShare}
                        >
                            {shareButtonText}
                        </button>
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