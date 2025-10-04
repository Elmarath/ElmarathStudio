import React from 'react';
import styles from './PortfolioBox.module.css';

const PortfolioBox = () => {
    return (
        <div className={styles.portfolioBox}>
            <div className={styles.openToWork}>Open To Work</div>
            <img 
                src="https://avatars.githubusercontent.com/u/65414809?v=4" 
                alt="Denizhan Toprak" 
                className={styles.profilePic} 
            />
            <h3 className={styles.name}>Denizhan Toprak</h3>
            <p className={styles.title}>C++ Gameplay Programmer</p>
            <p className={styles.description}>I have developed this site and specialize in game development</p>
        </div>
    );
};

export default PortfolioBox;
