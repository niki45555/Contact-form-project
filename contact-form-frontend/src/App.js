import React, { useState } from "react";

const App = () => {
	const [name, setName] = useState("");
	const [email, setEmail] = useState("");
	const [message, setMessage] = useState("");
	const [status, setStatus] = useState(null); // success, error, or null

	const handleSubmit = async (e) => {
		e.preventDefault();

		if (!name || !email || !message) {
			alert("Please fill in all fields.");
			return;
		}

		try {
			const response = await fetch("http://localhost:5000/send", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({ name, email, message }),
			});

			const data = await response.json();

			if (data.status === "success") {
				setStatus("success");
				setName("");
				setEmail("");
				setMessage("");
			} else {
				setStatus("error");
				console.error("Server error:", data.error || "Unknown");
			}
		} catch (error) {
			setStatus("error");
			console.error("Fetch error:", error);
		}
	};

	return (
		<div style={{ padding: "2rem", maxWidth: "500px", margin: "auto" }}>
			<h2>Contact Me</h2>
			<form onSubmit={handleSubmit}>
				<div style={{ marginBottom: "1rem" }}>
					<label>Name:</label>
					<input
						type="text"
						value={name}
						onChange={(e) => setName(e.target.value)}
						required
						style={{ width: "100%", padding: "0.5rem" }}
					/>
				</div>

				<div style={{ marginBottom: "1rem" }}>
					<label>Email:</label>
					<input
						type="email"
						value={email}
						onChange={(e) => setEmail(e.target.value)}
						required
						style={{ width: "100%", padding: "0.5rem" }}
					/>
				</div>

				<div style={{ marginBottom: "1rem" }}>
					<label>Message:</label>
					<textarea
						value={message}
						onChange={(e) => setMessage(e.target.value)}
						required
						rows="5"
						style={{ width: "100%", padding: "0.5rem" }}
					/>
				</div>

				<button type="submit" style={{ padding: "0.5rem 1rem" }}>
					Send Message
				</button>
			</form>

			{status === "success" && (
				<p style={{ color: "green", marginTop: "1rem" }}>
					✅ Message sent successfully!
				</p>
			)}
			{status === "error" && (
				<p style={{ color: "red", marginTop: "1rem" }}>
					❌ Failed to send message. Please try again.
				</p>
			)}
		</div>
	);
};

export default App;
