import React from 'react';
import styles from './HireBox.module.css'; // Assuming you have a CSS module for styling

const HireBox = () => {
    return (
        <div className={styles.hireBox}>
            <p><strong>Available For Hire</strong></p>
            <img src="https://avatars.githubusercontent.com/u/65414809?v=4" alt="Denizhan Toprak" className={styles.profilePic} />
            <p><strong>Email:</strong> <a href="mailto:toprakdenizhan19@gmail.com">toprakdenizhan19@gmail.com</a></p>
            <p><strong>CV:</strong> <a href="https://docs.google.com/document/d/1NyO2H-jLeTuhU76wPoMm6xU3kDFCQn3Dn-A5imPmtfA/edit?usp=sharing" target="_blank">Download CV</a></p>
        </div>
    );
};

export default HireBox;