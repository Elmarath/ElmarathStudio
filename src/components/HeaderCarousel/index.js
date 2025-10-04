import React, { useState, useEffect } from 'react';
import styles from './HeaderCarousel.module.css';

const HeaderCarousel = ({ children }) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isDesktop, setIsDesktop] = useState(false);
  const childrenArray = React.Children.toArray(children);

  useEffect(() => {
    const checkScreenSize = () => {
      setIsDesktop(window.innerWidth >= 1024);
    };

    checkScreenSize();
    window.addEventListener('resize', checkScreenSize);
    return () => window.removeEventListener('resize', checkScreenSize);
  }, []);

  const nextSlide = () => {
    setCurrentIndex((prev) => 
      prev === childrenArray.length - 1 ? 0 : prev + 1
    );
  };

  const prevSlide = () => {
    setCurrentIndex((prev) => 
      prev === 0 ? childrenArray.length - 1 : prev - 1
    );
  };

  const goToSlide = (index) => {
    setCurrentIndex(index);
  };

  // Touch/swipe handling
  const [touchStart, setTouchStart] = useState(null);

  const handleTouchStart = (e) => {
    setTouchStart(e.targetTouches[0].clientX);
  };

  const handleTouchEnd = (e) => {
    if (!touchStart) return;
    
    const touchEnd = e.changedTouches[0].clientX;
    const distance = touchStart - touchEnd;
    const isLeftSwipe = distance > 50;
    const isRightSwipe = distance < -50;

    if (isLeftSwipe) nextSlide();
    if (isRightSwipe) prevSlide();
    
    setTouchStart(null);
  };

  // Desktop: show all cards in a row
  if (isDesktop) {
    return (
      <div className={styles.desktopLayout}>
        {childrenArray.map((child, index) => (
          <div key={index} className={styles.desktopCard}>
            {child}
          </div>
        ))}
      </div>
    );
  }

  // Mobile/Tablet: carousel with peek view
  return (
    <div className={styles.carousel}>
      <div 
        className={styles.carouselContainer}
        onTouchStart={handleTouchStart}
        onTouchEnd={handleTouchEnd}
      >
        <div 
          className={styles.carouselTrack}
          style={{
            transform: `translateX(-${currentIndex * 100}%)`
          }}
        >
          {childrenArray.map((child, index) => (
            <div 
              key={index} 
              className={styles.carouselSlide}
              onClick={() => index !== currentIndex && goToSlide(index)}
            >
              <div className={styles.slideContent}>
                {child}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Navigation arrows */}
      <button 
        className={`${styles.carouselButton} ${styles.prevButton}`}
        onClick={prevSlide}
        aria-label="Previous card"
      >
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/>
        </svg>
      </button>
      
      <button 
        className={`${styles.carouselButton} ${styles.nextButton}`}
        onClick={nextSlide}
        aria-label="Next card"
      >
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M8.59 16.59L10 18l6-6-6-6-1.41 1.41L13.17 12z"/>
        </svg>
      </button>

      {/* Dots indicator */}
      <div className={styles.carouselDots}>
        {childrenArray.map((_, index) => (
          <button
            key={index}
            className={`${styles.dot} ${index === currentIndex ? styles.activeDot : ''}`}
            onClick={() => goToSlide(index)}
            aria-label={`Go to card ${index + 1}`}
          />
        ))}
      </div>
    </div>
  );
};

export default HeaderCarousel;
