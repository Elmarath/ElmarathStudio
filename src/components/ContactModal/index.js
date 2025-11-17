import React from 'react';
import { createPortal } from 'react-dom';
import { CONTACT_ITEMS } from '../../data';
import { ICON_MAP } from '../Icons';
import { useExternalLink } from '../../hooks';
import styles from './ContactModal.module.css';

/**
 * ContactModal Component - Displays contact information in a modal
 * @param {boolean} isOpen - Modal open state
 * @param {function} onClose - Function to close modal
 */
const ContactModal = ({ isOpen, onClose }) => {
  const { openLink } = useExternalLink();

  const handleContactAction = (item) => {
    switch (item.action) {
      case 'external':
        openLink(item.link);
        break;
      case 'navigate':
        window.location.href = item.link;
        break;
      case 'link':
      default:
        // Let the default link behavior handle it
        break;
    }
  };

  const renderContactItem = (item) => {
    const IconComponent = ICON_MAP[item.icon];
    const isClickable = item.action !== 'link';

    return (
      <div 
        key={item.id}
        className={`${styles.contactItem} ${isClickable ? styles.clickable : ''}`}
        onClick={isClickable ? () => handleContactAction(item) : undefined}
      >
        <div className={styles.iconContainer}>
          {IconComponent && (
            <IconComponent className={styles[`${item.icon}Icon`]} />
          )}
        </div>
        <div className={styles.contactInfo}>
          <span className={styles.contactLabel}>{item.label}</span>
          {item.action === 'link' ? (
            <a href={item.link} className={styles.contactLink}>
              {item.value}
            </a>
          ) : (
            <span className={styles.contactLink}>{item.value}</span>
          )}
        </div>
      </div>
    );
  };

  if (!isOpen) return null;

  return createPortal(
    <div className={styles.modalOverlay} onClick={onClose}>
      <div className={styles.contactModal} onClick={(e) => e.stopPropagation()}>
        <button className={styles.closeButton} onClick={onClose}>
          ×
        </button>
        
        <h2 className={styles.modalTitle}>Let's Connect!</h2>
        
        <div className={styles.modalContent}>
          {CONTACT_ITEMS.map(renderContactItem)}
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
    </div>,
    document.body
  );
};

export default ContactModal;