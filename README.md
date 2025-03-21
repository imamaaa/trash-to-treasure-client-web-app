# Trash to Treasure - Client Web App  

## Overview  
The **"Trash to Treasure" Client Web App** is part of my **Final Year Project (FYP)** that aims to tackle **low recycling rates and poor waste management** through an **AI-powered trash classification and incentivized rewards system**.  

Pakistan generates approximately **49.6 million tons of solid waste annually**, yet **only 3% of plastic waste is recycled locally**. The lack of proper waste segregation and incentives results in **mixed waste**, making recycling efforts inefficient.  

This system provides a **digital solution** that integrates:  

- **AI-based Trash Classification Module** → Classifies waste types for better segregation  
- **Smart Bin** → Displays QR codes/PINs after users dispose of waste  
- **Client Mobile App** → Allows users to scan QR codes, track recycling history, and earn points  
- **Client Web App** → Enables users to log into their accounts, track points, and manage rewards  
- **Admin Web App** → Used by shops & cafes to verify and redeem user rewards  

**This repository contains only the Client Web App** used by partnered shops and cafes.  

---

## Features  
- **Shop & Cafe Registration** → Businesses can register to participate in the rewards program.
- **QR Code Scanning** → Cashiers can **scan user QR codes** to validate and redeem rewards.
- **PIN Code Entry & Authentication** → If QR scanning is unavailable, cashiers can manually enter a PIN code.
- **Integration with Point System** → The web app updates the redemption status in the database.  

For more details on methodology, implementation, and results, refer to the FYP Report `(S24_008_D_TrashtoTreasure.pdf)`.

---

## Repository Contents  
- `web/` → **Web-specific files for the Flutter app**  
- `lib/` → **Flutter app source code (UI, logic, API integrations)**  
- `assets/` → **Images, icons, and static resources**  
- `pubspec.yaml` → **Dependencies & package configurations**  
- `README.md` → **Project documentation (to be expanded)**  
- `S24_008_D_TrashtoTreasure.pdf` → **Comprehensive project report detailing methodology & results**  

**This repository is for the Client Web App only.** Find related repositories here:  
- **[Client Mobile App Repo](https://github.com/imamaaa/trash-to-treasure-mobile-client-app)**  
- **[Admin Web App Repo](https://github.com/imamaaa/trash-to-treasure-admin-web-app)**  

---

## Future Enhancements:
- **Expand the README** with:  
   - **Setup & Installation Guide** to help users run the app.  
   - **System Architecture** explanation & API endpoint details.  
   - **Screenshots & UI Previews** for better visualization.  
   - **Demo Video/GIF** to showcase the app in action.  
   - **Challenges & Lessons Learned** section documenting obstacles & solutions.  

---
