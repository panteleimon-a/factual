import React, { useState, useEffect } from 'react';

const JoinWaitlistButton = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isPendingApproval, setIsPendingApproval] = useState(false);

  // Simulating checking the user's authentication status
  useEffect(() => {
    // Assume you have a function to check if the user is logged in
    const checkUserAuthentication = () => {
      // ... perform authentication check and set the state accordingly
      // For demonstration purposes, setting dummy values
      setIsLoggedIn(true); // Set to true if the user is logged in
      setIsPendingApproval(true); // Set to true if the user is awaiting approval
    };

    checkUserAuthentication();
  }, []);

  const handleJoinWaitlist = () => {
    if (isLoggedIn) {
      // Logic for handling join waitlist as logged in user
      console.log('Joining waitlist as logged in user');
    } else if (isPendingApproval) {
      // Logic for handling join waitlist as a user awaiting approval
      console.log('Your registration is pending approval');
    } else {
      // Logic for handling join waitlist as a guest
      console.log('Joining waitlist as guest');
    }
  };

  return (
    <button id="waitlist" onClick={handleJoinWaitlist}>
      {isLoggedIn
        ? 'Already joined'
        : isPendingApproval
        ? 'Your Registration is Pending Approval'
        : 'Join Waitlist'}
    </button>
  );
};

export default JoinWaitlistButton;