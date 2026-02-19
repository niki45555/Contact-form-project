const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');
const cors = require('cors');
const creds = require('./config');

const app = express();
const serverPort = 5000;

app.use(cors());
app.use(express.json());
app.use('/', router);

app.get('/', (req, res) => res.json('hi'));

// Transport config
const transport = {
	host: creds.HOST,
	port: creds.MAILPORT,
	secure: creds.MAILPORT === 465,
	auth: {
		user: creds.USER,
		pass: creds.PASS,
	},
};

const transporter = nodemailer.createTransport(transport);

transporter.verify((error, success) => {
	if (error) {
		console.error("Transport error:", error);
	} else {
		console.log('Server is ready to take messages');
	}
});

router.post('/send', (req, res) => {
	const { name, email, message } = req.body;
	if (!name || !email || !message) {
		return res.status(400).json({ status: 'fail', error: 'All fields required.' });
	}

	const content = `Name: ${name}\nEmail: ${email}\nMessage: ${message}`;
	const mail = {
		from: `${creds.YOURNAME} <${creds.EMAIL}>`,
		to: creds.EMAIL,
		subject: `New Portfolio Message from ${name}`,
		text: content,
	};

	transporter.sendMail(mail, (err, data) => {
		if (err) {
			console.error("Mail send error:", err);
			return res.status(500).json({ status: 'fail', error: err.message });
		}

		console.log('Primary mail sent:', data.response);

		// Auto-reply
		const reply = {
			from: `${creds.YOURNAME} <${creds.EMAIL}>`,
			to: email,
			subject: 'Message received',
			text: `Hi ${name},\nThank you for sending me a message. I will get back to you soon.`,
			html: `<p>Hi ${name},<br>Thank you for sending me a message. I will get back to you soon.</p>`,
		};

		transporter.sendMail(reply, (error, info) => {
			if (error) console.error("Auto-reply error:", error);
			else console.log('Auto-reply sent:', info.response);
		});

		res.json({ status: 'success' });
	});
});


app.listen(serverPort, () => console.log(`Backend is running on port ${serverPort}`));
