import React from "react";
//import styles from "./ReadmePage.css";
import styles from "./Application.less";

export default class ReadmePage extends React.Component {
	static getProps() {
		return {};
	}
	render() {
		var readme = { __html: require("./../../README.md") };
		return <div className={styles.this} dangerouslySetInnerHTML={readme}></div>;
	}
}
