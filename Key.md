# Program A New Key

To **program a new key** to your **2009 BMW 335i xDrive (E90/N54, CAS system)**, follow the **exact procedure below** depending on whether:

* 🔐 The **key is brand-new and unprogrammed** (e.g., eBay blank key with transponder)
* 📻 You want to **pair the remote functions** (lock/unlock)
* 🧠 You want the **car to recognize it and start the engine**

---

## 🔧 PART 1 — Requirements Overview

| Requirement           | Description                                                                   |
| --------------------- | ----------------------------------------------------------------------------- |
| **CAS module access** | Your car uses a CAS (Car Access System) — needs EEPROM reading                |
| **Key programmer**    | You need a **hardware tool** (BMW Standard Tools cannot program a fresh key!) |
| **Software options**  | AK90+, CGDI BMW, VVDI2, or BMW Explorer                                       |
| **Used key warning**  | Used keys from other cars must be **unlocked/reset** or they won’t work       |

---

## 🛠️ TOOLS NEEDED

| Tool                                                    | Purpose                                     |
| ------------------------------------------------------- | ------------------------------------------- |
| ✅ **AK90+ or CGDI BMW**                                 | Reads CAS data and writes key               |
| ✅ **Key programmer software (AK90.exe, CGDI Software)** | Interface to generate key                   |
| ❗ **Optional: INPA/NcsExpert/Tool32**                   | Verify coding, clear faults, sync key slots |

---

## 🔑 PART 2 — PROGRAM NEW KEY TO START THE ENGINE

### ▶️ Step-by-Step (Using AK90+ as example)

---

### 🧰 **Step 1: Connect AK90+ and Remove CAS EEPROM**

* Disconnect battery
* Locate **CAS module** (usually behind glove box)
* Remove CAS and find the EEPROM (often a 9S12 chip)
* Use the AK90+ adapter to **read the EEPROM** or connect via soldering points

---

### 🧠 **Step 2: Read EEPROM and Save the Dump**

* Open AK90 software
* Select CAS type (e.g., CAS3, CAS3+)
* Read the EEPROM data
* Save the dump (usually `.bin` or `.ep` file)

---

### 🔐 **Step 3: Generate a Key**

* Select an unused key slot (1–10)
* Insert your new key into the AK90 device
* Write the EEPROM data to that key slot
* Save the modified dump file

---

### 🔁 **Step 4: Write Back EEPROM to CAS**

* Reprogram the CAS EEPROM using the modified dump
* Reinstall the CAS module in your car
* Reconnect the battery

---

### 🚗 **Step 5: Test the New Key**

* Insert the new key into the slot
* Attempt to turn ignition ON
* Car should now recognize the key and allow you to start it

---

## 📻 PART 3 — PROGRAM REMOTE FUNCTION (Lock/Unlock)

If the **key starts the car but doesn’t lock/unlock**, do this:

### 🧰 Requirements:

* Car with keyless entry module (FZV)
* Working battery in the key fob

---

### 🔁 **Step-by-Step Remote Sync (Comfort Access OFF):**

1. Close all doors.
2. Insert key into ignition, turn to position 1 (dash lights on), then OFF.
3. Remove key.
4. **Within 5 seconds**, press and hold **unlock**.
5. While holding unlock, press **lock 3 times quickly**.
6. Release unlock.
7. Car should lock/unlock to confirm.
8. Repeat from step 4 for additional keys.

---

## ✅ VERIFY SLOT & FUNCTION WITH INPA / TOOL32

You can check if your new key is active using:

### 🔍 **INPA → CAS Module**

* Read key status
* View active slots
* Confirm key is recognized

---

## 💬 OPTIONAL: ENABLE KEY MEMORY / CODING

You can **customize per-key memory settings** with:

* **NcsExpert + NcsDummy**
* Module: **GM5**, **KOMBI**, or **CAS**

Enable features like:

* Per-key seat/mirror position
* Per-key HVAC memory
* Auto lock/unlock

---

## ⚠️ NOTES

* ❌ You **cannot use NcsExpert or WinKFP alone** to program a new virgin key.
* 🔁 **Used keys must be reset/unlocked** using VVDI2 or CGDI. AK90+ only supports new keys.


# Step-by-step guide for AK90+ software Usage

Here’s a detailed **step-by-step guide** to program a **new key** for your BMW **E90 (CAS3)** using the **AK90+** tool. This covers everything from removal of the CAS module to testing the key:

---

## 🧰 What You’ll Need

* **AK90+ key programmer** (USB adapter & software installed)
* **New blank key** with compatible transponder chip (e.g., PCF7935R)
* Basic tools to remove and re-install the CAS module

---

## 🔧 Step 1: Install AK90+ Software & Drivers

1. Run `AK90+ Setup.exe` to install the software.
2. Install the CP210x USB driver (found within the AK90 folder).
3. Connect AK90 via USB—Windows should recognize it (you may hear a beep).
4. Reboot the PC after installation ([obdii365.com][1], [obdii365.com][2]).

---

## 🔌 Step 2: Connect AK90+ and Verify

1. Plug AK90+ into the computer; listen for confirmation beep(s).
2. Open AK90 software **only after** device is connected ([obdii365.com][2]).
3. Place your **new key** into the AK90’s slot and click **Test Key** – it should detect a blank key with no VIN/mileage ([obdii365.com][1]).

---

## ⚙️ Step 3: Remove CAS Module

1. Disconnect the car battery for safety.
2. Inside the car (usually under the glove box), remove the CAS module by unscrewing clips.
3. Open the CAS casing to expose the EEPROM chip (typically OD46J).
4. Clean the chip contacts if needed to ensure a good connection ([obdii365.com][1]).

---

## 🔄 Step 4: Read CAS EEPROM

1. Connect CAS module to AK90 via the dedicated cable—align marked pin correctly ([obdii365.com][1]).
2. In AK90 software:

   * Select the correct chip (like OD46J).
   * Click **Read EWS** (or CAS) to read EEPROM data.
   * Save the dump (.bin file) as backup ([obdii365.com][1]).

---

## 🔑 Step 5: Analyze Existing Keys

1. Use **EWS Analyze** in AK90 to display key slots, VIN, and mileage.
2. Decide which slot (1–10) is free for the new key ([obdii365.com][1], [obdii365.com][2]).

---

## 🗝️ Step 6: Write New Key

1. With the **blank key** in the AK90 slot, click **Write Key**.
2. Select the desired slot (e.g., Slot 7).
3. Confirm the prompt and wait \~1–2 minutes for programming ([obdii365.com][1]).

---

## 🧩 Step 7: Write Modified EEPROM Back

1. After key write completes, AK90 will update the EEPROM image.
2. Click **Write EWS** again to program the modified dump back to the CAS module ([obdii365.com][1]).
3. Wait until completion (\~1–2 minutes).

---

## 🔄 Step 8: Reinstall CAS & Test

1. Close the CAS housing, reinstall it in the car, reconnect battery.
2. Test the new key:

   * **Test Key** again in AK90 to confirm its slot and data.
   * Insert it into the vehicle’s ignition and turn ON—the car should recognize it ([obdii365.com][1], [e46fanatics.com][3]).

---

## ✅ Step 9: Optional – Test Remote & Sync

If the key doesn’t lock/unlock:

1. Use **remote-sync** method:

   * Ignite to ON, then OFF and remove key.
   * Within seconds, press **Unlock**, then **Lock** three times.
   * Wait for lock/unlock chimes.
2. Alternatively, use **INPA or Tool32** to confirm the key is recognized by CAS.

---

### 🔍 Troubleshooting Tips

* Ensure chip selection matches exactly (e.g., OD46J).
* Fully align pins when reading/writing EEPROM.
* Don’t interrupt power during programming.
* Always save a backup of the original dump—bricking CAS can be costly.

---

## 📝 Summary Workflow

1. Install drivers → test blank key
2. Remove CAS → read EEPROM
3. Analyze slots → assign new key to free slot
4. Write key → write modified dump back
5. Reinstall CAS → test key in car
6. Sync remote if needed

---

Sources

[1]: https://www.obdii365.com/service/5-steps-to-program-a-bmw-e46-key-with-ak90-key-programmer-45571.html?srsltid=AfmBOop9fLD_WNm6vBc9xg9tUBl6HH1bN0uvdoxVa7BtoZeIER38omOi&utm_source=chatgpt.com "5 Steps to program a BMW E46 key with AK90 key programmer"
[2]: https://www.obdii365.com/upload/pro/bmw-ak90-key-programmer-user-manual.pdf?srsltid=AfmBOooX575WPGbrLghkRcnLydmYuV5xza3r3SOFxYWZ1Ca3jL7LWyDk&utm_source=chatgpt.com "[PDF] AK90 Operation - OBDII365.com"
[3]: https://www.e46fanatics.com/threads/diy-ak90-code-your-own-transponder-and-have-your-own-bmw-key.949007/?utm_source=chatgpt.com "DIY: Ak90 Code your own transponder and have your own BMW key"


Here's a **step‑by‑step guide with demo screenshots** (from AK90+ software interface) to help you program and sync a new key for your E90:

[Video Link](https://www.youtube.com/watch?v=pI_R3ifNmtw)

---

## 🖥️ Step‑by‑Step with Visuals

### 1. **Open AK90+ and Test Blank Key**

Plug AK90+ into your PC and insert the blank key:

* Click **Test Key**.
* **Screenshot**: You’ll see “No VIN”, “No mileage” — confirming a virgin key.

---

### 2. **Select CAS EEPROM and Read it**

* Choose your CAS chip version (e.g., OD46J or 9S12) from the dropdown.
* Click **Read EWS (CAS EEPROM)**.
* **Screenshot**: Progress bar ending with “Read successful” confirms dump saved.

---

### 3. **Analyze Existing Key Slots**

* Navigate to **EWS Analyze**.
* You should see a table of slots:

  * Slots filled → show VIN and mileage
  * Empty slot → displayed as “----”.
* Pick a free slot (e.g., Slot 7) for your new key.
* **Screenshot**: Highlight the free slot.

---

### 4. **Write the New Key**

* Insert new blank key.
* Click **Write Key** and choose the selected slot (e.g., Slot 7).
* Confirm in the popup, then wait \~90 sec.
* **Screenshot**: “Write Key success” message.

---

### 5. **Program Dump Back to CAS**

* Following success, AK90 generates an updated dump.
* Click **Write EWS (Back to CAS)** to program CAS.
* **Screenshot**: Progress and “Write successful” completion.

---

### 6. **Reinstall CAS Module**

* Reinsert CAS into the car, reconnect battery.
* Test new key in ignition:

  * Should turn ON
  * Dash lights illuminate, starter engages.

---

### 7. **Sync Remote (Lock/Unlock)**

If the remote buttons don't work:

1. Insert key, ignition ON → OFF, remove key.
2. Within 5 seconds, hold **Unlock**, then press **Lock** 3×.
3. Release **Unlock** — car locks/unlocks to confirm.

---

### ✅ Verified with INPA/Tool32

Optionally, connect INPA:

* Go to **CAS module → Read key slots** — your new key should be listed.

---

## 🚨 Tips & Precautions

* Ensure software shows the **correct chip type** before reading/writing.
* Save original dump in multiple locations.
* Never interrupt power during the write process.
* Use the **remote‑sync method** right after programming to avoid misrecognition.

Here’s a **detailed visual walkthrough** of programming your **new blank key** for your 2009 E90 (CAS/EWS) using the **AK90+ tool**:

---

## 🎥 Watch This Demo First

A great AK90+ step-by-step guide—covering blank key detection, EEPROM read/write, and writing the key—is available:

[BMW AK90+ EWS‑3 Key Programming Walkthrough](https://www.youtube.com/watch?v=pI_R3ifNmtw&utm_source=chatgpt.com)

---

## 🛠️ Step-by-Step Guide with Screenshots & Tips

### 1. **Install AK90+ Software & Drivers**

* Run `AK90+ Setup.exe` to install the application.
* Install the Silicon Labs CP210x USB driver for the AK90 hardware ([obdii365.com][1], [ncs-expert.com][2]).
* Plug in AK90: you should hear a "Bi" beep once, then three beeps after opening the software ([obdii365.com][1]).
* ✅ Important: Always connect the device **before** launching the software.

---

### 2. **Test Your New (Blank) Key**

* Insert the blank key into the AK90 slot.
* Click **Test Key** in the software.
* The display should show *no VIN/mileage*—confirming the key is virgin ([obd2tool.com][3], [ncs-expert.com][2]).

---

### 3. **Remove & Expose CAS/EWS Module**

* Safely disconnect the vehicle’s battery.
* Locate the CAS/EWS module beneath the steering column (or glovebox).
* Unscrew and pull it out, opening its housing to reveal the EEPROM chip ([ncs-expert.com][2]).
* Clean the chip contacts gently to ensure a good connection.

---

### 4. **Connect Module to AK90 & Read EEPROM**

* Use the AK90 cable to connect to the EEPROM—align the marked dot on the connector with the chip ([obd2tool.com][3], [ncs-expert.com][2]).
* In AK90 software: select the correct chip type (e.g., OD46J).
* Click **Read EWS** (or CAS EEPROM).
* Save the dump file—this backup is crucial ([ncs-expert.com][2]).
* Optional: click **EWS Analyze** to view occupied key slots, VIN, and mileage ([ncs-expert.com][2]).

---

### 5. **Write New Key Data**

* Insert the new blank key into AK90.
* Click **Write Key** and choose a free slot (e.g., slot 7).
* Confirm the action and allow \~1–2 minutes for the process to finish ([ncs-expert.com][2]).

---

### 6. **Flash Updated EEPROM Back into CAS/EWS**

* After key programming, click **Write EWS** to write the updated dump back to the module.
* Wait \~1–2 minutes until the "Write successful" message appears ([ncs-expert.com][2]).

---

### 7. **Reinstall Module & Test Key in Car**

* Refit the module housing and reinstall it in the vehicle.
* Reconnect the battery.
* Test the key:

  * Insert it into ignition—dash lights or engine start should work.
  * If it starts and runs, coding was successful.

---

### 8. **Optional: Sync Remote Buttons**

If the remote (lock/unlock) isn't working:

1. Turn ignition ON → OFF → remove key.
2. Within 5 seconds: hold **Unlock**, press **Lock** three times, then release **Unlock**.
3. Car should lock/unlock confirming sync.

---

## ✅ Quick Tips & Warnings

* Press connectors firmly during read/write for consistent connection ([ncs-expert.com][2], [e46fanatics.com][4], [scribd.com][5]).
* If “pin no touch” error occurs, rotate the connector 90° and ensure clean contacts ([ncs-expert.com][2]).
* Always save backups of original dumps—interruptions can brick the CAS.
* Blank key transponders often hide near the battery—check placement if key test fails ([ncs-expert.com][2]).
* Once done, test in software via **Test Key** and in-car ignition.

---

### 🛡️ Optional Verification

Use INPA or Tool32 to read CAS data and confirm the new key slot is active post-installation.

---

[1]: https://www.obdii365.com/upload/pro/bmw-ak90-key-programmer-user-manual.pdf?srsltid=AfmBOood9nAcrQjZQhufGbmd8sQLMK7ji1NSVwVV0ljrl95nhIAyWqVg&utm_source=chatgpt.com "[PDF] AK90 Operation - OBDII365.com"
[2]: https://ncs-expert.com/e46-key-programming-ak90-guide?utm_source=chatgpt.com "E46 Key Programming- AK90 Guide - NCS-Expert.com"
[3]: https://www.obd2tool.com/blog/the-way-of-operating-for-bmw-ak90-key-programmer/?utm_source=chatgpt.com "The way of Operating For BMW AK90+ Key Programmer - OBD2TOOL"
[4]: https://www.e46fanatics.com/threads/diy-ak90-code-your-own-transponder-and-have-your-own-bmw-key.949007/?utm_source=chatgpt.com "DIY: Ak90 Code your own transponder and have your own BMW key"
[5]: https://www.scribd.com/document/483150887/bmw-ak90-key-programmer-user-manual?utm_source=chatgpt.com "BMW Ak90 Key Programmer User Manual | PDF - Scribd"
