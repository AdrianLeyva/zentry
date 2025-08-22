-----

# Zentry 🛡️

**AI-Powered Local Network Scanner – Flutter App**

Zentry is an innovative mobile and desktop application focused on cybersecurity, developed with Flutter. It allows users to scan and evaluate their local networks with AI-powered intelligent analysis.

-----

#### Network Scanner
![Network Scanner](assets/network_scanner.gif)

#### Packet Sniffer
![Packet Sniffer](assets/packet_sniffer.gif)

#### AI Assistant
![AI Assistant](assets/ai_assistant.gif)

-----

## 🚀 Features

- 🔍 **Local Network Scanning** Detects all connected devices and open ports in the local network.

- 🛰️ **Packet Sniffing** Captures and analyzes network packets to give deeper insights into network traffic.

- 🧠 **AI Evaluation** Uses artificial intelligence to analyze network structure, detect vulnerabilities, and provide improvement suggestions.

- 🌐 **Flutter Multiplatform** Developed with Flutter for a seamless experience on Android & iOS.

## 🛠️ Tech Stack

- Flutter
- Dart (Primary language)
- Platform Channels for native integration (Android/iOS)
- BLoC for state management
- Custom libraries for network scanning and analysis
- Integration with external AI for evaluation and recommendations

## 📦 Installation

To build locally, you'll first need to configure your **Gemini API key**.

1.  **Get your Gemini API Key:**

<!-- end list -->

* Go to [Google AI Studio](https://aistudio.google.com/app/apikey) and generate a new API key.

<!-- end list -->

2.  **Add the key to your project:**

<!-- end list -->

* Rename the `dotenv.example` file in the project's root directory to **`.env`**.
* Open the newly renamed `.env` file and replace `YOUR_API_KEY_HERE` with your actual key:
  ```
  GEMINI_API_KEY=YOUR_API_KEY_HERE
  ```
* The `.env` file is excluded from version control for security.

After setting up your API key, you can build the project:

```bash
git clone https://github.com/AdrianLeyva/zentry.git
cd zentry
flutter pub get
flutter build
```

-----

### 🤝 Ethical Use and Responsibility

The use of **Zentry** is intended exclusively for **personal security and analysis** of local networks that you own or for which you have explicit permission.

-----

#### 🔒 Fundamental Principles

* **Consent:** Always obtain explicit permission before scanning or analyzing a network that is not your own.
* **Responsibility:** You are solely responsible for your actions when using this application. Use Zentry ethically and legally.

-----

#### ⚖️ Legal Warning

The use of network security tools in unauthorized environments is illegal in many jurisdictions and may result in civil and criminal penalties. **Zentry** is designed for the **auditing of authorized home and business networks** and should not be used for **ethical or black-box hacking** without the network owner's consent.

By using Zentry, you accept these terms and agree to use the application responsibly and in compliance with the law.