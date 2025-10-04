import React, { useState } from 'react';
import Link from '@docusaurus/Link';
import styles from './PortfolioBox.module.css';

const PortfolioBox = () => {
    const [showContactModal, setShowContactModal] = useState(false);
    
    const contactEmail = "toprakdenizhan19@gmail.com";
    const linkedinUrl = "https://tr.linkedin.com/in/denizhan-toprak-006073193";

    const handleOpenToWorkClick = (e) => {
        e.preventDefault();
        setShowContactModal(true);
    };

    const closeModal = () => {
        setShowContactModal(false);
    };

    const handleModalClick = (e) => {
        if (e.target === e.currentTarget) {
            closeModal();
        }
    };

    return (
        <>
            <div className={styles.portfolioBox}>
                <button 
                    onClick={handleOpenToWorkClick}
                    className={styles.openToWork}
                >
                    Open To Work
                </button>
                <img 
                    src="https://avatars.githubusercontent.com/u/65414809?v=4" 
                    alt="Denizhan Toprak" 
                    className={styles.profilePic} 
                />
                <h3 className={styles.name}>Denizhan Toprak</h3>
                <p className={styles.title}>C++ Gameplay Programmer</p>
                <Link to="/blog/About Me" className={styles.descriptionLink}>
                    <p className={styles.description}>
                        Hi, I am the solo developer of all the documented plugins on this site! 
                        Check out what I have done and learn more about me.
                    </p>
                </Link>
            </div>

            {showContactModal && (
                <div className={styles.modalOverlay} onClick={handleModalClick}>
                    <div className={styles.contactModal}>
                        <button className={styles.closeButton} onClick={closeModal}>×</button>
                        
                        {/* Decorative connection icons */}
                        <div className={styles.decorativeIcons}>
                            <svg className={styles.networkIcon1} viewBox="0 0 24 24" fill="currentColor">
                                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                            </svg>
                            <svg className={styles.networkIcon2} viewBox="0 0 24 24" fill="currentColor">
                                <path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3z"/>
                            </svg>
                            <svg className={styles.networkIcon3} viewBox="0 0 24 24" fill="currentColor">
                                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                            </svg>
                        </div>

                        <h3 className={styles.modalTitle}>You can reach me from:</h3>
                        
                        <div className={styles.contactItem}>
                            <div className={styles.iconContainer}>
                                <svg className={styles.mailIcon} viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
                                </svg>
                            </div>
                            <div className={styles.contactInfo}>
                                <span className={styles.contactLabel}>Email:</span>
                                <a href={`mailto:${contactEmail}`} className={styles.contactLink}>
                                    {contactEmail}
                                </a>
                            </div>
                        </div>

                        <div className={styles.contactItem}>
                            <div className={styles.iconContainer}>
                                <svg className={styles.linkedinIcon} viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                                </svg>
                            </div>
                            <div className={styles.contactInfo}>
                                <span className={styles.contactLabel}>LinkedIn:</span>
                                <a href={linkedinUrl} target="_blank" rel="noopener noreferrer" className={styles.contactLink}>
                                    View Profile
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </>
    );
};

export default PortfolioBox;
