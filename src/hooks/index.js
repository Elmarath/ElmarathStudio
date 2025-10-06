import { useState, useEffect } from 'react';

/**
 * Custom hook for managing modal state with body scroll lock
 * @param {boolean} initialState - Initial modal state
 * @returns {object} Modal state and control functions
 */
export const useModal = (initialState = false) => {
  const [isOpen, setIsOpen] = useState(initialState);

  const open = () => setIsOpen(true);
  const close = () => setIsOpen(false);
  const toggle = () => setIsOpen(prev => !prev);

  // Body scroll lock effect
  useEffect(() => {
    if (isOpen) {
      // Save current scroll position
      const scrollY = window.scrollY;
      // Lock body scroll
      document.body.style.position = 'fixed';
      document.body.style.top = `-${scrollY}px`;
      document.body.style.width = '100%';
      document.body.style.overflow = 'hidden';
    } else {
      // Restore scroll position and unlock body scroll
      const scrollY = document.body.style.top;
      document.body.style.position = '';
      document.body.style.top = '';
      document.body.style.width = '';
      document.body.style.overflow = '';
      if (scrollY) {
        window.scrollTo(0, parseInt(scrollY || '0') * -1);
      }
    }

    // Cleanup function to restore scroll on unmount
    return () => {
      document.body.style.position = '';
      document.body.style.top = '';
      document.body.style.width = '';
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  return { isOpen, open, close, toggle };
};

/**
 * Custom hook for handling external links
 * @returns {function} Function to open external links safely
 */
export const useExternalLink = () => {
  const openLink = (url, target = '_blank') => {
    if (url) {
      window.open(url, target, 'noopener,noreferrer');
    }
  };

  return { openLink };
};

/**
 * Custom hook for search functionality
 * @param {Array} items - Items to search through
 * @param {string} searchKey - Key to search in items
 * @returns {object} Search state and filtered results
 */
export const useSearch = (items, searchKey = 'title') => {
  const [searchTerm, setSearchTerm] = useState('');

  const filteredItems = items.filter(item =>
    item[searchKey]?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.description?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const clearSearch = () => setSearchTerm('');

  return {
    searchTerm,
    setSearchTerm,
    filteredItems,
    clearSearch,
    hasResults: filteredItems.length > 0,
    isSearching: searchTerm.length > 0
  };
};