import React, { useState } from 'react';
import HeaderCard from '../HeaderCard';
import ContactModal from '../ContactModal';
import PDFViewer from '../PDFViewer';
import { PERSONAL_INFO } from '../../constants';
import { useModal } from '../../hooks';
import styles from './PortfolioBox.module.css';

/**
 * PortfolioBox Component - Displays personal portfolio card with contact modal
 */
const PortfolioBox = () => {
    const contactModal = useModal();
    const [pdfViewerOpen, setPdfViewerOpen] = useState(false);

    const handleCardClick = (e) => {
        // Only open modal if the click wasn't on any button
        if (!e.target.closest('button')) {
            contactModal.open();
        }
    };

    const handleDescriptionClick = (e) => {
        e.stopPropagation();
        window.location.href = PERSONAL_INFO.blogPath;
    };

    const handleResumeClick = (e) => {
        e.stopPropagation();
        setPdfViewerOpen(true);
    };

    const handleClosePdfViewer = () => {
        setPdfViewerOpen(false);
    };

    return (
        <>
            <HeaderCard onClick={handleCardClick}>
                <button 
                    className={styles.openToWork}
                    onClick={(e) => {
                        e.stopPropagation();
                        contactModal.open();
                    }}
                >
                    Hire Me
                </button>
                
                <button 
                    className={styles.resumeButton}
                    onClick={handleResumeClick}
                >
                    📄 View Resume
                </button>
                
                <img 
                    src={PERSONAL_INFO.avatar}
                    alt={PERSONAL_INFO.name}
                    className={styles.profilePic} 
                />
                
                <h3 className={styles.name}>{PERSONAL_INFO.name}</h3>
                <p className={styles.title}>{PERSONAL_INFO.title}</p>
                
                <div className={styles.descriptionLink} onClick={handleDescriptionClick}>
                    <p className={styles.description}>
                        {PERSONAL_INFO.description}
                    </p>
                </div>
            </HeaderCard>

            <ContactModal 
                isOpen={contactModal.isOpen} 
                onClose={contactModal.close} 
            />
            
            <PDFViewer
                isOpen={pdfViewerOpen}
                onClose={handleClosePdfViewer}
                pdfUrl="/docs/DenizhanToprak_Resume.pdf"
                title="Denizhan Toprak - Resume"
                downloadFileName="DenizhanToprak_Resume.pdf"
            />
        </>
    );
};

export default PortfolioBox;
