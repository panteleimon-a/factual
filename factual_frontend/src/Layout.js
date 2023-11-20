
import { Outlet } from "react-router-dom"
import CustomNavbar from "./navbar"

export default function Layout() {
    return (
        <>  
            <header>
                <CustomNavbar />
            </header>
            <main>                
                <Outlet />
            </main>
            <footer>

            </footer>
        </>
    )
}



