import React from 'react';
import HeaderCard from '../HeaderCard';
import styles from './HeaderBox.module.css';

const HeaderBox = () => {
    return (
        <HeaderCard>
            <img 
                src="/img/T_ElmarathLogo.png" 
                alt="Elmarath Studio Logo" 
                className={styles.logo} 
            />
            <h2 className={styles.title}>Elmarath Studio</h2>
            <p className={styles.description}>Professional Game Development Tools</p>
        </HeaderCard>
    );
};

export default HeaderBox;
