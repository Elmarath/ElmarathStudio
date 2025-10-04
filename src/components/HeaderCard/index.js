import React from 'react';
import styles from './HeaderCard.module.css';

const HeaderCard = ({ 
  children, 
  onClick, 
  className = '', 
  onMouseEnter, 
  onMouseLeave,
  style = {} 
}) => {
  return (
    <div 
      className={`${styles.headerCard} ${className}`}
      onClick={onClick}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
      style={style}
    >
      {children}
    </div>
  );
};

export default HeaderCard;
