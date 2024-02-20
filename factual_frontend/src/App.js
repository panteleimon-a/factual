
//import './App.css';
import './Styles.css'
import { Route, Routes } from 'react-router-dom';
import React, { useState, useEffect } from 'react';
import Layout from './Layout';
import Home from './Home';
import SearchResults from './SearchResults';
import Profile from './Profile';
import Login from './Login';

import 'bootstrap/dist/css/bootstrap.min.css';


function App() {
  const [showLoginModal, setShowLoginModal] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  useEffect(() => {
      const token = localStorage.getItem('token');
      setIsLoggedIn(!!token);
  }, []);


  const [user, setUser] = useState({});

  const [userProfile, setUserProfile] = useState({});
  useEffect(() => {
    const fetchProfile = async () => {
      try{
        if (localStorage.getItem('token') !== null){
          console.log(localStorage.getItem('token'));
          const token = localStorage.getItem('token').toString();     
            try {
              const response = await fetch('http://127.0.0.1:8000/account/get_profile/', {
                method: 'GET',
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': `Bearer ${token}`,
                },
              });

              if (response.ok) {
                const profileData = await response.json();

                const user_temp = profileData.user;
                const user_profile_temp = profileData.user_profile;
                setUser(user_temp);
                setUserProfile(user_profile_temp);
              } else {
                console.error('Error fetching profile:', response.statusText);
              }
            } catch (error) {
              console.error('Error fetching profile:', error.message);
            }
        }
      }catch{}
    };

    fetchProfile();
  }, []);


  const refreshToken = async () => {
    try {

      const refreshToken = localStorage.getItem('refresh_token').toString();

      const response = await fetch('http://127.0.0.1:8000/account/token/refresh/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',

        },
        body: JSON.stringify({
          refresh: refreshToken,
        }),
      });
      console.log(response);
      if (response.ok) {
        const data = await response.json();
        console.log(data);

        const accessToken = data.access;
        const refreshToken = data.refresh;
        localStorage.setItem('token', accessToken);
        localStorage.setItem('refresh_token', refreshToken);

        console.log(data.refresh);
        console.log(data.access);
        return data.access;
      } else {
        throw new Error('Failed to refresh access token');
      }
    } catch (error) {
      console.error('Error refreshing token:', error.message);
    }
  };

  useEffect(() => {
    // Refresh token every 59 minutes
    const refreshTokenInterval = setInterval(refreshToken,  59 * 60 * 1000);

    // Cleanup function to clear the interval on component unmount
    return () => clearInterval(refreshTokenInterval);
  }, []);

  return (
    <div className="App">
        <Routes> 
            <Route path="/" element={<Layout isLoggedIn={isLoggedIn} setIsLoggedIn={setIsLoggedIn} />}>
              <Route index element={<Home isLoggedIn={isLoggedIn} setShowLoginModal={setShowLoginModal} isBetaAuthenticated={userProfile.beta_authenticated}/>} />
              <Route
                path="/profile"
                element={<Profile user={user} userProfile={userProfile}  />}
              />
              <Route path="search-results" element={<SearchResults />} />
           </Route>
        </Routes>
        <Login isLoggedIn={isLoggedIn} setIsLoggedIn={setIsLoggedIn} showLoginModal={showLoginModal} setShowLoginModal={setShowLoginModal} />
    </div>

  );
}

export default App;
