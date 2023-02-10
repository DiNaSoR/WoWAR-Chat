-- Addon: WoWinArabic-Chat (version: 10.00) 2023.02.10
-- Note: The addon supports chat for entering and displaying messages in Arabic.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)
-- Special thanks for DragonArab for helping to create letter reshaping rules.


-- General Variables
local CH_version = GetAddOnMetadata("WoWinArabic_Chat", "Version");
local CH_ED_mode = 0;      -- włączony tryb arabski, wyrównanie do prawej strony
local CH_ED_insert = 0;    -- tryb przesuwania kursora po wpisaniu litery

-- fonty z arabskimi znakami
local CH_Font = "Interface\\AddOns\\WoWinArabic_Chat\\Fonts\\calibri.ttf";


-------------------------------------------------------------------------------------------------------

local function CH_Check_Arabic_Letters(txt)
   local result = false;
   if (txt) then
      local bytes = strlen(txt);
      local pos = 1;
      local char0 = '';
      local charbytes0;
      while (pos <= bytes) do
         charbytes0 = AS_UTF8charbytes(txt, pos);         -- count of bytes (liczba bajtów znaku)
         char0 = strsub(txt, pos, pos + charbytes0 - 1);  -- current character
			pos = pos + charbytes0;
         if ((char0 >= "؀") and (char0 <= "ݿ")) then      -- it is a arabic letter
            result = true;
            break;
         end
      end
   end
   return result;
end

-------------------------------------------------------------------------------------------------------

local function CH_ChatFilter(self, event, arg1, arg2, arg3, _, arg5, ...)
   local colorText = "";
   
   if (event == "CHAT_MSG_SAY") then
      colorText = "|cFFFFFFFF";
   elseif (event == "CHAT_MSG_PARTY") then
      colorText = "|cFFAAAAFF";
   elseif (event == "CHAT_MSG_YELL") then
      colorText = "|cFFFF4040";
   elseif (event == "CHAT_MSG_WHISPER") then
      colorText = "|cFFFFB5EB";
   end

   local is_arabic = CH_Check_Arabic_Letters(arg1);
   if (is_arabic) then
      local poz = string.find(arg2, "-");
      local output = "";
      local playerLen = AS_UTF8len(string.sub(arg2, 1, poz-1));
		local playerLink = CH_UTF8reverse(GetPlayerLink(arg2, ("[|cFFBC9F73%s|r]"):format(string.sub(arg2, 1, poz-1)), arg11));
      if (event == "CHAT_MSG_SAY") then
         output = playerLink.." يتحدث: ";           -- said
         local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME:GetFont(); -- odczytaj aktualną czcionkę, rozmiar i typ
         DEFAULT_CHAT_FRAME:SetFont(CH_Font, _sizeC, _C);
         DEFAULT_CHAT_FRAME:AddMessage(colorText..CH_LineChat(output..CH_UTF8reverse(arg1), _sizeC, 45));   -- 4=count of unwritable characters (color)
      elseif (event == "CHAT_MSG_PARTY") then
         output = playerLink..": ";           
         local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME:GetFont(); -- odczytaj aktualną czcionkę, rozmiar i typ
         DEFAULT_CHAT_FRAME:SetFont(CH_Font, _sizeC, _C);
         DEFAULT_CHAT_FRAME:AddMessage(colorText..CH_LineChat(output..CH_UTF8reverse(arg1), _sizeC, 45));   -- 4=count of unwritable characters (color)
      elseif (event == "CHAT_MSG_WHISPER") then
         output = playerLink.." همس: ";            -- whisped
         local _fontW, _sizeW, _W = DEFAULT_CHAT_FRAME:GetFont(); -- odczytaj aktualną czcionkę, rozmiar i typ
         ChatFrame11:SetFont(CH_Font, _sizeW, _W);                -- na kanale WHISPER
      else
         return false;  -- wyświetlaj tekst oryginalny w oknie czatu
      end   
      return true;      -- nie wyświetlaj oryginalnego tekstu
   else
      return false;     -- wyświetlaj tekst oryginalny w oknie czatu
   end   
end


-------------------------------------------------------------------------------------------------------

function CH_OnTextChanged()
   if (CH_ED_mode == 1) then        -- mamy tryb arabski
      if (CH_ED_insert == 0) then
         DEFAULT_CHAT_FRAME.editBox:SetCursorPosition(DEFAULT_CHAT_FRAME.editBox:SetCursorPosition()-1);      -- przesuń kursor na lewo od aktualnej litery
      end
   end
end

-------------------------------------------------------------------------------------------------------

local function CH_AR_ON_OFF()
   local txt = DEFAULT_CHAT_FRAME.editBox:GetText();
   if (CH_ED_mode == 0) then        -- mamy tryb EN - przełącz na tryb arabski
      DEFAULT_CHAT_FRAME.editBox:SetJustifyH("RIGHT");
      DEFAULT_CHAT_FRAME.editBox:SetCursorPosition(0);         -- przesuń kursor na skrajne lewo
      CH_ToggleButton:SetNormalFontObject("GameFontNormal");   -- litery AR żółte
      CH_ToggleButton:SetText("AR");
      CH_ED_mode = 1;      
      CH_InsertButton:Show();
   else
      DEFAULT_CHAT_FRAME.editBox:SetJustifyH("LEFT");
      DEFAULT_CHAT_FRAME.editBox:SetCursorPosition(AS_UTF8len(txt));  -- przesuń kursor na skrajne prawo
      CH_ToggleButton:SetNormalFontObject("GameFontRed");      -- litery EN czerwone
      CH_ToggleButton:SetText("EN");
      CH_ED_mode = 0;
      CH_InsertButton:Hide();
   end
   ChatEdit_ActivateChat(DEFAULT_CHAT_FRAME.editBox);
   DEFAULT_CHAT_FRAME.editBox:SetFocus();
end

-------------------------------------------------------------------------------------------------------

local function CH_INS_ON_OFF()
   if (CH_ED_insert == 0) then         -- mamy tryb przesuwania kursowa na lewo
      CH_InsertButton:SetText("→");
      CH_ED_insert = 1;                -- włącz tryb przesuwania na prawo od wpisanego znaku
   else
      CH_InsertButton:SetText("←");
      CH_ED_insert = 0;
   end
   DEFAULT_CHAT_FRAME.editBox:SetFocus();
end
-------------------------------------------------------------------------------------------------------

local function CH_OnEvent(self, event, name, ...)
   if (event=="ADDON_LOADED" and name=="WoWinArabic_Chat") then
      CH_Frame:UnregisterEvent("ADDON_LOADED");
      local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME:GetFont(); -- odczytaj aktualną czcionkę, rozmiar i typ
      DEFAULT_CHAT_FRAME:SetFont(CH_Font, _sizeC, _C);
      local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME.editBox:GetFont(); -- odczytaj aktualną czcionkę, rozmiar i typ
      DEFAULT_CHAT_FRAME.editBox:SetFont(CH_Font, _sizeC, _C);
      DEFAULT_CHAT_FRAME.editBox:SetScript("OnTextChanged", CH_OnTextChanged);      -- aby zmieniał pozycję kursora przy wprowadzaniu liter arabskich
      
      CH_ToggleButton = CreateFrame("Button", nil, DEFAULT_CHAT_FRAME, "UIPanelButtonTemplate");
      CH_ToggleButton:SetWidth(34);
      CH_ToggleButton:SetHeight(20);
      CH_ToggleButton:SetNormalFontObject("GameFontRed");      -- litery EN czerwone
      CH_ToggleButton:SetText("EN");
      CH_ToggleButton:Show();
      CH_ToggleButton:ClearAllPoints();
      CH_ToggleButton:SetPoint("TOPRIGHT", DEFAULT_CHAT_FRAME, "BOTTOMLEFT", -1, -6);
      CH_ToggleButton:SetScript("OnClick", CH_AR_ON_OFF);

      CH_InsertButton = CreateFrame("Button", nil, DEFAULT_CHAT_FRAME.editBox, "UIPanelButtonTemplate");
      CH_InsertButton:SetWidth(28);
      CH_InsertButton:SetHeight(20);
      CH_InsertButton.Text:SetFont(CH_Font, 14, _C);
      CH_InsertButton:SetText("←");
      CH_InsertButton:Hide();
      CH_InsertButton:ClearAllPoints();
      CH_InsertButton:SetPoint("TOPLEFT", DEFAULT_CHAT_FRAME.editBox, "TOPRIGHT", -9, -7);
      CH_InsertButton:SetScript("OnClick", CH_INS_ON_OFF);

      ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CH_ChatFilter)
      ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", CH_ChatFilter)
      ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", CH_ChatFilter)
      ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CH_ChatFilter)
      ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", CH_ChatFilter)
      ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", CH_ChatFilter)
      DEFAULT_CHAT_FRAME:AddMessage("|cffffff00WoWinArabic-Chat ver. "..CH_version.." - started");
      CH_Frame.ADDON_LOADED = nil;
   end
end

-------------------------------------------------------------------------------------------------------

function CH_CreateTestLine()
   CH_TestLine = CreateFrame("Frame", "CH_TestLine", UIParent, "BasicFrameTemplateWithInset");
   CH_TestLine:SetHeight(150);
   CH_TestLine:SetWidth(DEFAULT_CHAT_FRAME:GetWidth()+50);
   CH_TestLine:ClearAllPoints();
   CH_TestLine:SetPoint("TOPLEFT", 20, -300);
   CH_TestLine.title = CH_TestLine:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
   CH_TestLine.title:SetPoint("CENTER", CH_TestLine.TitleBg);
   CH_TestLine.title:SetText("Frame for testing width of text");
   CH_TestLine.ScrollFrame = CreateFrame("ScrollFrame", nil, CH_TestLine, "UIPanelScrollFrameTemplate");
   CH_TestLine.ScrollFrame:SetPoint("TOPLEFT", CH_TestLine.InsetBg, "TOPLEFT", 10, -40);
   CH_TestLine.ScrollFrame:SetPoint("BOTTOMRIGHT", CH_TestLine.InsetBg, "BOTTOMRIGHT", -5, 10);
  
   CH_TestLine.ScrollFrame.ScrollBar:ClearAllPoints();
   CH_TestLine.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", CH_TestLine.ScrollFrame, "TOPRIGHT", -12, -18);
   CH_TestLine.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", CH_TestLine.ScrollFrame, "BOTTOMRIGHT", -7, 15);
   CHchild = CreateFrame("Frame", nil, CH_TestLine.ScrollFrame);
   CHchild:SetSize(552,100);
   CHchild.bg = CHchild:CreateTexture(nil, "BACKGROUND");
   CHchild.bg:SetAllPoints(true);
   CHchild.bg:SetColorTexture(0, 0.05, 0.1, 0.8);
   CH_TestLine.ScrollFrame:SetScrollChild(CHchild);
   CH_TestLine.text = CHchild:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
   CH_TestLine.text:SetPoint("TOPLEFT", CHchild, "TOPLEFT", 2, 0);
   CH_TestLine.text:SetText("");
   CH_TestLine.text:SetSize(DEFAULT_CHAT_FRAME:GetWidth(),0);
   CH_TestLine.text:SetJustifyH("LEFT");
   CH_TestLine.CloseButton:SetPoint("TOPRIGHT", CH_TestLine, "TOPRIGHT", 0, 0);
   CH_TestLine:Hide();     -- the frame is invisible in the game
end

-------------------------------------------------------------------------------------------------------

-- function formats arabic text for display in a left-justified chat line
function CH_LineChat(txt, font_size, more_chars)
   local retstr = "";
   if (txt and font_size) then
      local more_chars = more_chars or 0;
      local chat_width = DEFAULT_CHAT_FRAME:GetWidth();             -- width of 1 chat line
      local chars_limit = chat_width / (0.35*font_size+0.8)*1.1 ;   -- so much max. characters can fit on one line
		local bytes = strlen(txt);
		local pos = 1;
      local counter = 0;
      local second = 0;
		local newstr = "";
		local charbytes;
      local newstrR;
      local char1;
		while (pos <= bytes) do
			c = strbyte(txt, pos);                      -- read the character (odczytaj znak)
			charbytes = AS_UTF8charbytes(txt, pos);    -- count of bytes (liczba bajtów znaku)
         char1 = strsub(txt, pos, pos + charbytes - 1);
			newstr = newstr .. char1;
			pos = pos + charbytes;
         
         counter = counter + 1;
         if ((char1 >= "A") and (char1 <= "z")) then
            counter = counter + 1;        -- latin letters are 2x wider, then Arabic
         end
         if ((char1 == " ") and (counter-more_chars>=chars_limit-3)) then      -- break line here
            newstrR = CH_AddSpaces(AS_UTF8reverse(newstr), second);
            retstr = retstr .. newstrR .. "\n";
            newstr = "";
            counter = 0;
            more_chars = 0;
            second = 2;
         end
      end
      newstrR = CH_AddSpaces(AS_UTF8reverse(newstr), second);
      retstr = retstr .. newstrR;
      retstr = string.gsub(retstr, "\n ", "\n");        -- space after newline code is useless
   end
	return retstr;
end

-------------------------------------------------------------------------------------------------------

-- the function appends spaces to the left of the given text so that the text is aligned to the right
function CH_AddSpaces(txt, snd)                                 -- snd = second or next line (interspace 2 on right)
   local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME:GetFont();     -- read current font, size and flag of the chat object
   local chat_widthC = DEFAULT_CHAT_FRAME:GetWidth();           -- width of 1 chat line
   local chars_limitC = chat_widthC / (0.35*_sizeC+0.8);        -- so much max. characters can fit on one line
   
   if (CH_TestLine == nil) then     -- a own frame for displaying the translation of texts and determining the length
      CH_CreateTestLine();
   end   
   CH_TestLine:SetWidth(DEFAULT_CHAT_FRAME:GetWidth()+50);
   CH_TestLine:Hide();     -- the frame is invisible in the game
   CH_TestLine.text:SetFont(_fontC, _sizeC, _C);
   local count = 0;
   local text = txt;
   CH_TestLine.text:SetText(text);
   while ((CH_TestLine.text:GetHeight() < _sizeC*1.5) and (count < chars_limitC)) do
      count = count + 1;
      text = " "..text;
      CH_TestLine.text:SetText(text);
   end

   if (count < chars_limitC) then    -- failed to properly add leading spaces
      for i=4,count-snd,1 do         -- spaces are added to the left of the text
         txt = " "..txt;
      end
   end
   CH_TestLine.text:SetText(txt);
   
   return(txt);
end

-------------------------------------------------------------------------------------------------------

-- Reverses the order of UTF-8 letters, without arabic reshaping
function CH_UTF8reverse(s)
   local newstr = "";
   if (s) then                                   -- check if argument is not empty (nil)
      local bytes = strlen(s);
      local pos = 1;
      local char1;
      local charbytes1;

      while (pos <= bytes) do
         charbytes1 = AS_UTF8charbytes(s, pos);         -- count of bytes (liczba bajtów znaku)
         char1 = strsub(s, pos, pos + charbytes1 - 1);  -- current character
			pos = pos + charbytes1;
         newstr = char1 .. newstr;
      end
   end
   return newstr;
end

-------------------------------------------------------------------------------------------------------

CH_Frame = CreateFrame("Frame");
CH_Frame:RegisterEvent("ADDON_LOADED");
CH_Frame:SetScript("OnEvent", CH_OnEvent);
