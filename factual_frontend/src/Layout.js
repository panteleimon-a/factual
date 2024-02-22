
import { Outlet, useNavigate  } from "react-router-dom"
import CustomNavbar from "./navbar"
import React from 'react';
export default function Layout({ isLoggedIn, setIsLoggedIn }) {
    
  const navigate = useNavigate();
 
  const handleLogout = () => {
    // Simply remove the token from local storage
    localStorage.removeItem('token');
    // Update the state to reflect the user's logout status
    setIsLoggedIn(false);

    navigate('/', { replace: true });
    window.location.reload();
  };
  
    return (
        <>  
            <header>
                <CustomNavbar isLoggedIn={isLoggedIn} setIsLoggedIn={setIsLoggedIn} handleLogout={handleLogout}/>
            </header>
            <main>                
                <Outlet  isLoggedIn={isLoggedIn}/>
            </main>
            <footer>

            </footer>
        </>
    )
}



