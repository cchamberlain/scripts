import React from 'react'
import { Link } from 'react-router'
import ReactLogo from 'elements/ReactLogo'

import { Button, Navbar, Nav, NavItem, NavDropdown, MenuItem } from 'react-bootstrap';


const wellStyles = {maxWidth: 400, margin: '0 auto 10px'};


export default class MainMenu extends React.Component {
	render() {
		return <Navbar brand="hackr" inverse toggleNavKey={0}>
    <Nav right eventKey={0}> {/* This is the eventKey referenced */}
      <NavItem eventKey={1}><Link to="/home">home</Link></NavItem>
      <NavItem eventKey={2}><Link to="/chat/hackr">chat/hackr</Link></NavItem>
      <NavDropdown eventKey={3} title="Dropdown" id="collapsible-navbar-dropdown">
        <MenuItem eventKey="1">Action</MenuItem>
        <MenuItem eventKey="2">Another action</MenuItem>
        <MenuItem eventKey="3">Something else here</MenuItem>
        <MenuItem divider />
        <MenuItem eventKey="4">Separated link</MenuItem>
      </NavDropdown>
    </Nav>
  </Navbar>
	}
}
