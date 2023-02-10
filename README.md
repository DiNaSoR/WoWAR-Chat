# WoWinArabic-Chat
This is an addon for the MMORPG World of Warcraft that supports chat in Arabic.

## Features
- The addon allows players to enter and display messages in Arabic
- The addon is equipped with special fonts that display Arabic characters correctly
- The chat text is aligned to the right side, as per the traditional writing style of the Arabic language
- The cursor is shifted to the right after entering each letter to reflect the traditional typing style for Arabic text

## Author
- Platine (email: platine.wow@gmail.com)
- Special thanks to DragonArab for helping to create letter reshaping rules

## Version
- Version: 10.00, released on 2023.02.07

## Technical Details
The addon is implemented in Lua and makes use of the following functions:

- CH_Check_Arabic_Letters(txt): checks if a given text string contains Arabic letters
- CH_ChatFilter(self, event, arg1, arg2, arg3, _, arg5, ...): filters chat messages and displays them in the desired format, using the specified font and alignment

## Limitations
The current version of the addon has the following limitations:

- Only works in World of Warcraft
- Supports only the Arabic language

## Conclusion
This addon provides a convenient way for World of Warcraft players who prefer to communicate in Arabic to do so within the game. It is simple to use and enhances the player's overall gaming experience.
