import React, { useState } from 'react';
import HeaderCard from '../HeaderCard';
import styles from './PortfolioBox.module.css';

const PortfolioBox = () => {
    const [isContactModalOpen, setIsContactModalOpen] = useState(false);

    const openContactModal = () => {
        setIsContactModalOpen(true);
    };

    const closeContactModal = () => {
        setIsContactModalOpen(false);
    };

    const openLinkedIn = () => {
        window.open('https://www.linkedin.com/in/denizhan-toprak-006073193/', '_blank');
    };

    return (
        <>
            <HeaderCard>
                <button 
                    className={styles.openToWork}
                    onClick={openContactModal}
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
                <div className={styles.descriptionLink} onClick={() => window.location.href = '/blog/About Me'}>
                    <p className={styles.description}>
                        Professional game developer specializing in Unreal Engine solutions. I have independently developed all the plugins and tools featured on this platform. I would be delighted to discuss potential collaboration opportunities.
                    </p>
                </div>
            </HeaderCard>

            {/* Contact Modal */}
            {isContactModalOpen && (
                <div className={styles.modalOverlay} onClick={closeContactModal}>
                    <div className={styles.contactModal} onClick={(e) => e.stopPropagation()}>
                        <button className={styles.closeButton} onClick={closeContactModal}>
                            ×
                        </button>
                        
                        <h2 className={styles.modalTitle}>Let's Connect!</h2>
                        
                        <div className={styles.contactItem}>
                            <div className={styles.iconContainer}>
                                <svg className={styles.mailIcon} fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z"/>
                                    <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z"/>
                                </svg>
                            </div>
                            <div className={styles.contactInfo}>
                                <span className={styles.contactLabel}>Email</span>
                                <a 
                                    href="mailto:toprakdenizhan19@gmail.com" 
                                    className={styles.contactLink}
                                >
                                    toprakdenizhan19@gmail.com
                                </a>
                            </div>
                        </div>

                        <div className={styles.contactItem} onClick={openLinkedIn} style={{cursor: 'pointer'}}>
                            <div className={styles.iconContainer}>
                                <svg className={styles.linkedinIcon} fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M16.338 16.338H13.67V12.16c0-.995-.017-2.277-1.387-2.277-1.39 0-1.601 1.086-1.601 2.207v4.248H8.014v-8.59h2.559v1.174h.037c.356-.675 1.227-1.387 2.526-1.387 2.703 0 3.203 1.778 3.203 4.092v4.711zM5.005 6.575a1.548 1.548 0 11-.003-3.096 1.548 1.548 0 01.003 3.096zm-1.337 9.763H6.34v-8.59H3.667v8.59zM17.668 1H2.328C1.595 1 1 1.581 1 2.298v15.403C1 18.418 1.595 19 2.328 19h15.34c.734 0 1.332-.582 1.332-1.299V2.298C19 1.581 18.402 1 17.668 1z" clipRule="evenodd"/>
                                </svg>
                            </div>
                            <div className={styles.contactInfo}>
                                <span className={styles.contactLabel}>LinkedIn</span>
                                <span className={styles.contactLink}>
                                    Connect with me on LinkedIn
                                </span>
                            </div>
                        </div>

                        <div className={styles.contactItem} onClick={() => window.open('https://docs.google.com/document/d/1NyO2H-jLeTuhU76wPoMm6xU3kDFCQn3Dn-A5imPmtfA/edit?usp=sharing', '_blank')} style={{cursor: 'pointer'}}>
                            <div className={styles.iconContainer}>
                                <svg className={styles.linkedinIcon} fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2H4zm2 3a1 1 0 011-1h6a1 1 0 110 2H7a1 1 0 01-1-1zm1 4a1 1 0 100 2h6a1 1 0 100-2H7z" clipRule="evenodd"/>
                                </svg>
                            </div>
                            <div className={styles.contactInfo}>
                                <span className={styles.contactLabel}>Resume/CV</span>
                                <span className={styles.contactLink}>
                                    View my professional CV
                                </span>
                            </div>
                        </div>

                        <div className={styles.contactItem} onClick={() => window.open('https://github.com/Elmarath', '_blank')} style={{cursor: 'pointer'}}>
                            <div className={styles.iconContainer}>
                                <svg className={styles.linkedinIcon} fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M10 0C4.477 0 0 4.484 0 10.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0110 4.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.203 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.942.359.31.678.921.678 1.856 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0020 10.017C20 4.484 15.522 0 10 0z" clipRule="evenodd"/>
                                </svg>
                            </div>
                            <div className={styles.contactInfo}>
                                <span className={styles.contactLabel}>GitHub Profile</span>
                                <span className={styles.contactLink}>
                                    View all my projects
                                </span>
                            </div>
                        </div>

                        {/* Decorative background icons */}
                        <div className={styles.decorativeIcons}>
                            <svg className={styles.networkIcon1} fill="currentColor" viewBox="0 0 20 20">
                                <path fillRule="evenodd" d="M12.395 2.553a1 1 0 00-1.45-.385c-.345.23-.614.558-.822.88-.214.33-.403.713-.57 1.116-.334.804-.614 1.768-.84 2.734a31.365 31.365 0 00-.613 3.58 2.64 2.64 0 01-.945-1.067c-.328-.68-.398-1.534-.398-2.654A1 1 0 005.05 6.05 6.981 6.981 0 003 11a7 7 0 1011.95-4.95c-.592-.591-.98-.985-1.348-1.467-.363-.476-.724-1.063-1.207-2.03zM12.12 15.12A3 3 0 017 13s.879.5 2.5.5c0-1 .5-4 1.25-4.5.5 1 .786 1.293 1.371 1.879A2.99 2.99 0 0113 13a2.99 2.99 0 01-.879 2.121z" clipRule="evenodd"/>
                            </svg>
                            <svg className={styles.networkIcon2} fill="currentColor" viewBox="0 0 20 20">
                                <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z"/>
                            </svg>
                            <svg className={styles.networkIcon3} fill="currentColor" viewBox="0 0 20 20">
                                <path fillRule="evenodd" d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2H4zm2.5 3A1.5 1.5 0 019 5.5v1.25a3 3 0 004.5 2.598V10a2 2 0 01-2 2H8.5a2 2 0 01-2-2V7z" clipRule="evenodd"/>
                            </svg>
                        </div>
                    </div>
                </div>
            )}
        </>
    );
};

export default PortfolioBox;
