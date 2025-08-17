# Sending Zabbix Alerts to Telegram

This guide walks you through setting up **Zabbix** to send alerts to a Telegram chat using a bot. It’s straightforward, human-friendly, and tested to work. Let’s get started!

---

## **1. Create a Telegram Bot and Get the API Token**

1. Open Telegram and message `@BotFather`.
2. Send the `/newbot` command.
3. Choose a name and username for your bot (username must end with `_bot`, e.g., `@MyZabbixBot`).
4. BotFather will provide an **API Token**, which looks something like:

   ```
   123456789:AAE4z...abcd
   ```

5. Save this token securely—you’ll need it later.

---

## **2. Find the Chat ID**

1. Add your bot to a Telegram group or start a private chat with it.
2. Open a browser and visit:

   ```
   https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
   ```

   Replace `<YOUR_TOKEN>` with the bot’s API token.

3. Send a test message to the bot or group.
4. In the JSON response, look for `chat.id`. This is your **Chat ID**. It could be a negative number for groups or a positive one for personal chats.

---

## **3. Create a Script to Send Messages**

On your Zabbix server, create a script in the alert scripts directory (usually `/usr/lib/zabbix/alertscripts/` or `/usr/lib/zabbix/externalscripts/`):

```bash
nano /usr/lib/zabbix/alertscripts/telegram.sh
```

Add the following content:

```bash
#!/bin/bash
TOKEN="YOUR_TOKEN_HERE"
CHAT_ID="YOUR_CHAT_ID_HERE"
MESSAGE="$1"

curl -s -X POST https://api.telegram.org/bot$TOKEN/sendMessage \
    -d chat_id=$CHAT_ID \
    -d text="$MESSAGE" \
    -d parse_mode="Markdown"
```

Replace `YOUR_TOKEN_HERE` and `YOUR_CHAT_ID_HERE` with your bot’s token and chat ID.

Then, make the script executable:

```bash
chmod +x /usr/lib/zabbix/alertscripts/telegram.sh
```

---

## **4. Set Up a Media Type in Zabbix**

1. Go to **Administration → Media types → Create media type**.
2. Configure:
   - **Name**: `Telegram`
   - **Type**: `Script`
   - **Script name**: `telegram.sh`
   - **Script parameters**: Add `{ALERT.MESSAGE}`
3. Check **Enabled** and click **Add**.

---

## **5. Assign Media to a User**

1. Navigate to **Administration → Users** and select a user.
2. Open the **Media** tab and click **Add**.
3. Configure:
   - **Type**: `Telegram`
   - **Send to**: Leave blank (it’s defined in the script).
   - **When active**: `1-7,00:00-24:00` (sends alerts any time, any day).
   - **Severity**: Choose which alert levels to send (e.g., High, Disaster).
4. Save the changes.

---

## **6. Create a Trigger**

1. Go to **Configuration → Hosts** and select a host.
2. Open the **Triggers** tab and click **Create trigger**.
3. Configure:
   - **Name**: e.g., `High CPU Load`
   - **Expression**: Example for CPU load above 5:
     ```
     {MyHost:system.cpu.load[percpu,avg1].last()} > 5
     ```
   - **Severity**: Choose a level (e.g., High or Disaster).
4. Save the trigger.

---

## **7. Create an Action to Send Alerts**

1. Go to **Configuration → Actions → Trigger actions → Create action**.
2. Configure:
   - **Name**: `Send to Telegram`
   - **Conditions**:
     - Add: `Trigger severity >= High`
   - **Operations**:
     - **Send message to**: Select the user.
     - **Send only to**: `Telegram`
3. Save the action.

---

## **8. Test the Setup**

1. Trigger a condition to activate the alert (e.g., simulate high CPU load) or use Zabbix’s **Test Action** feature.
2. Check your Telegram chat—you should see the alert message!

---

## **Troubleshooting Tips**

- **No alerts in Telegram?**
  - Verify the `telegram.sh` script permissions (`chmod +x`).
  - Ensure the `TOKEN` and `CHAT_ID` in the script are correct.
  - Check Zabbix server logs for errors.
- **Formatting issues?**
  - The script uses `Markdown` for formatting. If it’s not rendering properly, try changing `parse_mode` to `HTML` or remove it.
- **Curl not working?**
  - Ensure `curl` is installed on the Zabbix server (`sudo apt install curl` or equivalent).

---

That’s it! You’ve now got Zabbix sending alerts straight to your Telegram. If you run into issues or have questions, feel free to reach out or check the Zabbix and Telegram API documentation for more details.

Happy monitoring! 🚀
```
