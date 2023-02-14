-- Addon: WoWinArabic-Chat (version: 10.00) 2023.02.14
-- Note: The addon supports chat for entering and displaying messages in Arabic.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)
-- Special thanks for DragonArab for helping to create letter reshaping rules.


-- General Variables
local CH_version = GetAddOnMetadata("WoWinArabic_Chat", "Version");
local CH_ctrFrame = CreateFrame("FRAME", "WoWinArabic-Chat");
local CH_ED_mode = 0;           -- włączony tryb arabski, wyrównanie do prawej strony
local CH_ED_cursor_move = 0;    -- tryb przesuwania kursora po wpisaniu litery (0-w lewo, 1-w prawo)
local CH_BubblesArray = {};
local CH_BuforEditBox = {};
local limit_chars1 = 30;    -- max. number of 1 line on bubble (one-line bubble)
local limit_chars2 = 50;    -- max. number of 2 line on bubble (two-lines bubble)

-- fonty z arabskimi znakami
local CH_Font = "Interface\\AddOns\\WoWinArabic_Chat\\Fonts\\calibri.ttf";


-------------------------------------------------------------------------------------------------------

local function CH_bubblizeText()
   for _, bubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
   -- Iterate the children, as the actual bubble content 
   -- has been placed in a nameless subframe in 9.0.1.
      for i = 1, bubble:GetNumChildren() do
         local child = select(i, select(i, bubble:GetChildren()));
         if not child:IsForbidden() then                       -- czy ramka nie jest zabroniona?
            if (child:GetObjectType() == "Frame") and (child.String) and (child.Center) then
            -- This is hopefully the frame with the content
               for i = 1, child:GetNumRegions() do
                  local region = select(i, child:GetRegions());
                  for idx, iArray in ipairs(CH_BubblesArray) do      -- sprawdź, czy dane są właściwe (tekst oryg. się zgadza z zapisaną w tablicy)
                     if region and not region:GetName() and region:IsVisible() and region.GetText and (region:GetText() == iArray[1]) then
                        act_font = 18;
                        region:SetFont(CH_Font, act_font);             -- ustaw arabską czcionkę oraz niezmienioną wielkość (13)
                        local newText = AS_UTF8reverse(iArray[2]);   -- text reshaped
                        if ((AS_UTF8len(newText) >= limit_chars2) or (region:GetHeight() > act_font*3)) then    -- 3 lines or more
                           region:SetJustifyH("RIGHT");              -- wyrównanie do prawej strony (domyślnie jest CENTER)
                           newText = CH_LineReverse(iArray[2], 3);
                           region:SetText(newText);
                        elseif ((AS_UTF8len(newText) >= limit_chars1) or (region:GetHeight() > act_font*2)) then   -- 2 lines
                           region:SetJustifyH("RIGHT");              -- wyrównanie do prawej strony
                           newText = CH_LineReverse(iArray[2], 2);
                           region:SetText(newText);
                        else                                         -- bubble in 1-line
                           region:SetJustifyH("CENTER");             -- wyrównanie do środka
                           region:SetText(newText);                  -- wpisz tu nasze tłumaczenie
                        end
                        region:SetWidth(CH_SpecifyBubbleWidth(newText, region));  -- określ nową szer. okna
                        tremove(CH_BubblesArray, idx);               -- usuń zapamiętane dane z tablicy
                     end
                  end
               end
            end
         end
      end
   end

   for idx, iArray in ipairs(CH_BubblesArray) do            -- przeszukaj jeszcze raz tablicę
      if (iArray[3] >= 100) then                            -- licznik osiągnął 100
         tremove(CH_BubblesArray, idx);                     -- usuń zapamiętane dane z tablicy
      else
         iArray[3] = iArray[3]+1;                           -- zwiększ licznik (nie pokazał się dymek?)
      end;
   end;
   if (#(CH_BubblesArray) == 0) then
      CH_ctrFrame:SetScript("OnUpdate", nil);               -- wyłącz metodę Update, bo tablica pusta
   end;
end;

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
      local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME:GetFont();    -- odczytaj aktualną czcionkę, rozmiar i typ
      if (event == "CHAT_MSG_SAY") then
         output = playerLink..CH_UTF8reverse(" :يتحدث ");         -- said
         DEFAULT_CHAT_FRAME:SetFont(CH_Font, _sizeC, _C);
         DEFAULT_CHAT_FRAME:AddMessage(colorText..CH_LineChat(output..CH_UTF8reverse(arg1), _sizeC)); 
         tinsert(CH_BubblesArray, { [1] = arg1, [2] = CH_UTF8reverse(arg1), [3] = 1 });
         CH_ctrFrame:SetScript("OnUpdate", CH_bubblizeText);
      elseif (event == "CHAT_MSG_PARTY") then
         output = playerLink..": ";           
         DEFAULT_CHAT_FRAME:SetFont(CH_Font, _sizeC, _C);
         DEFAULT_CHAT_FRAME:AddMessage(colorText..CH_LineChat(output..CH_UTF8reverse(arg1), _sizeC)); 
      elseif (event == "CHAT_MSG_WHISPER") then
         output = playerLink..CH_UTF8reverse(" :همس ");           -- whisped
         local _fontW, _sizeW, _W = DEFAULT_CHAT_FRAME:GetFont(); -- odczytaj aktualną czcionkę, rozmiar i typ
         ChatFrame11:SetFont(CH_Font, _sizeW, _W);                -- na kanale WHISPER
      elseif (event == "CHAT_MSG_YELL") then
         output = playerLink..CH_UTF8reverse(" :يصرخ ");          -- yelled
         DEFAULT_CHAT_FRAME:SetFont(CH_Font, _sizeC, _C);
         DEFAULT_CHAT_FRAME:AddMessage(colorText..CH_LineChat(output..CH_UTF8reverse(arg1), _sizeC)); 
      else
         return false;  -- wyświetlaj tekst oryginalny w oknie czatu
      end   
      return true;      -- nie wyświetlaj oryginalnego tekstu
   else
      return false;     -- wyświetlaj tekst oryginalny w oknie czatu
   end   
end


-------------------------------------------------------------------------------------------------------

local function CH_AR_ON_OFF()       -- funkcja włącz/wyłącza tryb arabski
   local txt = DEFAULT_CHAT_FRAME.editBox:GetText();
   if (CH_ED_mode == 0) then        -- mamy tryb EN - przełącz na tryb arabski
      DEFAULT_CHAT_FRAME.editBox:SetJustifyH("RIGHT");
      DEFAULT_CHAT_FRAME.editBox:SetCursorPosition(0);         -- przesuń kursor na skrajne lewo
      CH_ToggleButton:SetNormalFontObject("GameFontNormal");   -- litery AR żółte
      CH_ToggleButton:SetText("AR");
      CH_ED_mode = 1;
      DEFAULT_CHAT_FRAME.editBox:SetCursorPosition(0);         -- przesuń kursor na skrajne lewo
      CH_ED_cursor_move = 0;
      CH_InsertButton:SetText("←");
      CH_InsertButton:Show();
   else
      DEFAULT_CHAT_FRAME.editBox:SetJustifyH("LEFT");
      DEFAULT_CHAT_FRAME.editBox:SetCursorPosition(AS_UTF8len(txt));  -- przesuń kursor na skrajne prawo
      CH_ToggleButton:SetNormalFontObject("GameFontRed");      -- litery EN czerwone
      CH_ToggleButton:SetText("EN");
      CH_ED_mode = 0;
      DEFAULT_CHAT_FRAME.editBox:SetCursorPosition(strlen(DEFAULT_CHAT_FRAME.editBox:GetText()));   -- przesuń kursor na skrajne prawo
      CH_ED_cursor_move = 1;
      CH_InsertButton:SetText("→");
      CH_InsertButton:Hide();
   end
   ChatEdit_ActivateChat(DEFAULT_CHAT_FRAME.editBox);
   DEFAULT_CHAT_FRAME.editBox:SetFocus();
end

-------------------------------------------------------------------------------------------------------

local function CH_INS_ON_OFF()            -- funkcja przełącza przesuwanie kursowa w zależności od wprowadzonej litery
   if (CH_ED_cursor_move == 0) then       -- mamy tryb przesuwania kursowa na lewo
      CH_InsertButton:SetText("→");
      CH_ED_cursor_move = 1;              -- włącz tryb przesuwania na prawo od wpisanego znaku
   else
      CH_InsertButton:SetText("←");
      CH_ED_cursor_move = 0;              -- włącz tryb przesuwania w lewo od wpisanego znaku
   end
   DEFAULT_CHAT_FRAME.editBox:SetFocus();
end

-------------------------------------------------------------------------------------------------------

function CH_OnTextChanged()
   if (CH_ED_mode == 1) then        -- mamy tryb arabski
      if (CH_ED_cursor_move == 0) then
         DEFAULT_CHAT_FRAME.editBox:SetCursorPosition(DEFAULT_CHAT_FRAME.editBox:GetCursorPosition()-1);      -- przesuń kursor na lewo od aktualnej litery
      end
   end
end

-------------------------------------------------------------------------------------------------------

local function CH_OnChar(self, character)
   local spaces = "( )?؟!,.;:،";             -- letters that we treat as a space
   if (AS_UTF8find(spaces, character)) then
      if (CH_ED_cursor_move == 0) then       -- mamy tryb przesuwania w lewo
         if (character == "(") then          -- nawiasy trzeba zamienić ( --> )
            local poz0 = self:GetCursorPosition();
            local oldtxt = self:GetText();
            local newtxt = AS_UTF8sub(oldtxt, 1, poz0-1) .. ")" .. AS_UTF8sub(oldtxt, poz0+1);
            self:SetText(newtxt);
            self:SetCursorPosition(poz0);
         elseif (character == ")") then
            local poz0 = self:GetCursorPosition();
            local oldtxt = self:GetText();
            local newtxt = AS_UTF8sub(oldtxt, 1, poz0-1) .. "(" .. AS_UTF8sub(oldtxt, poz0+1);
            self:SetText(newtxt);
            self:SetCursorPosition(poz0);
         end
         self:SetCursorPosition(self:GetCursorPosition()-strlen(character));  -- przesuń kursor na lewo od ostatniego znaku (spacja, nawiasy, przecinek, kropka)
      end         
   else
      if ((character >= "؀") and (character <= "ݿ")) then   -- it is a arabic letter
         if (CH_ED_cursor_move == 1) then    -- mamy tryb przesuwania w prawo - przełącz na tryb przesuwania w lewo od wpisanego znaku
            CH_INS_ON_OFF();                 -- zmień na przesuwanie w lewo
         end
         self:SetCursorPosition(self:GetCursorPosition()-strlen(character));  -- przesuń kursor na lewo od aktualnej litery
      else                                               -- wprowadzono literę inną niż arabska
         if (CH_ED_cursor_move == 0) then    -- mamy tryb przesuwania w lewo - przełącz na tryb przesuwania w prawo od wpisanego znaku
            CH_INS_ON_OFF();
         end
      end
   end
end

-------------------------------------------------------------------------------------------------------

function CH_OnKeyDown(self, key)    -- wciśnięto klawisz key
   if (CH_ED_mode == 1) then        -- mamy tryb arabski
      if (key == "BACKSPACE") then  -- usuń znak poprzedzający, czyli 1 na prawo
         local buf = self:GetText();
         local pos = self:GetCursorPosition();
         if (strlen(buf) > 0) then         -- nie jest pusty tekst
            if (pos < strlen(buf)) then                  -- kursor nie jest na początku tekstu, skrajnie na prawo
               local charbytes;
               if (pos == 0) then          -- kursor jest na końcu tekstu, skrejnie w lewo
                  charbytes = AS_UTF8charbytes(buf, 1);
               else
                  charbytes = AS_UTF8charbytes(buf, pos);   -- liczba bajtów 1 znaku w pozycji pos
               end;
               self:SetCursorPosition(pos+charbytes);    -- przesuń kursor o 1 znak w prawo, aby usunięcie było tego znaku
            else
               self:SetText(buf.." ");
               self:SetCursorPosition(strlen(buf)+1);    -- przesuń kursor na początek tekstu w prawo, aby usunąć tę spację
            end
         end
         
      elseif (key == "DELETE") then                -- usuń znak następujący, czyli 1 na lewo
         local buf = self:GetText();
         local pos = self:GetCursorPosition();
         if (pos > 0) then                         -- kursor nie jest na końcu tekstu, skrajnie w lewo
            -- ustal znak z lewej strony
            pos = pos - 1;
            if (pos > 0) then
               local c = strbyte(buf, pos);
               while (c >= 128 and c <= 191) do
                  pos = pos - 1;
                  c = strbyte(bbuf, pos);
               end
            end
            self:SetCursorPosition(pos);    -- przesuń kursor o 1 znak w lewo, aby usunięcie było tego znaku
         else                             -- kursor jest na końcu tekstu, nie ma co usuwać - dodaj spację na końcu
            self:SetText(" "..buf);
            self:SetCursorPosition(0);    -- przesuń kursor na koniec tekstu w lewo, aby usunąć tę spację
         end
         
      end
   end
end

-------------------------------------------------------------------------------------------------------

function CH_OnKeyUp(self, key)      -- pyszczono klawisz key
   if (CH_ED_mode == 1) then        -- mamy tryb arabski
      if (key == "HOME") then       -- skocz kursorem na początek tekstu, czyli na skreajne prawo
         self:SetCursorPosition(strlen(self:GetText()));
         
      elseif (key == "END") then    -- skocz kursorem na koniec tekstu, czyli na skrajne lewo
         self:SetCursorPosition(0);
         
      end
   end
end

-------------------------------------------------------------------------------------------------------

local function CH_OnEvent(self, event, name, ...)
   if (event=="ADDON_LOADED" and name=="WoWinArabic_Chat") then
      CH_Frame:UnregisterEvent("ADDON_LOADED");
      local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME:GetFont(); -- odczytaj aktualną czcionkę, rozmiar i typ
      DEFAULT_CHAT_FRAME:SetFont(CH_Font, _sizeC, _C);
      local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME.editBox:GetFont(); -- odczytaj aktualną czcionkę, rozmiar i typ
      DEFAULT_CHAT_FRAME.editBox:SetFont(CH_Font, _sizeC, _C);
--      DEFAULT_CHAT_FRAME.editBox:SetScript("OnTextChanged", CH_OnTextChanged);      -- aby zmieniał pozycję kursora przy wprowadzaniu liter arabskich
      DEFAULT_CHAT_FRAME.editBox:SetScript("OnChar", CH_OnChar);       -- aby zmieniał pozycję kursora przy wprowadzaniu kolejnych liter
      DEFAULT_CHAT_FRAME.editBox:SetScript("OnKeyDown", CH_OnKeyDown); -- wciśnięto jakiś klawisz
      DEFAULT_CHAT_FRAME.editBox:SetScript("OnKeyUp", CH_OnKeyUp);     -- puszczono jakiś klawisz
      
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
      if (CH_TestLine == nil) then     -- a own frame for displaying the translation of texts and determining the length
         CH_CreateTestLine();
      end   
		local bytes = strlen(txt);
		local pos = 1;
      local counter = 0;
      local second = 0;
      local link_start_stop = false;
		local newstr = "";
      local nextstr = "";
		local charbytes;
      local newstrR;
      local char1, char2;
		while (pos <= bytes) do
         counter = counter + 1;
			c = strbyte(txt, pos);                      -- read the character (odczytaj znak)
			charbytes = AS_UTF8charbytes(txt, pos);     -- count of bytes (liczba bajtów znaku)
         char1 = strsub(txt, pos, pos + charbytes - 1);
			newstr = newstr .. char1;
			pos = pos + charbytes;                 -- text for Platine: اختبر TEST ربتخا
         if (pos <= bytes) then
	         charbytes = AS_UTF8charbytes(txt, pos);     -- count of bytes (liczba bajtów znaku)
            char2 = strsub(txt, pos, pos + charbytes - 1);
         else
            char2 = "";
         end
         if ((char1..char2 == "r|") and (pos > 70)) then           -- start of the link
            link_start_stop = true;
         elseif ((char1..char2 == "c|") and (pos > 70)) then       -- end of the link
            link_start_stop = false;
         end
         
         if ((char1 == " ") and (link_start_stop == false)) then     -- mamy spację, ale nie wewnątrz linku
            nextstr = "";
         else
            nextstr = nextstr .. char1;
         end
         
         CH_TestLine.text:SetWidth(DEFAULT_CHAT_FRAME:GetWidth());
         CH_TestLine.text:SetText(AS_UTF8reverse(newstr));
         if ((CH_TestLine.text:GetHeight() > font_size*1.5) and (link_start_stop == false)) then   -- tekst nie mieści się już w 1 linii
            newstr = AS_UTF8sub(newstr, 1, AS_UTF8len(newstr)-AS_UTF8len(nextstr));   -- tekst do ostatniej spacji
            newstrR = CH_AddSpaces(AS_UTF8reverse(newstr), second);
            retstr = retstr .. newstrR .. "\n";
            newstr = nextstr;
            nextstr = "";
            counter = 0;
            second = 2;  
         end
      end
      newstrR = CH_AddSpaces(AS_UTF8reverse(newstr), second);
      retstr = retstr .. newstrR;
      retstr = string.gsub(retstr, " \n", "\n");        -- space before newline code is useless
      retstr = string.gsub(retstr, "\n ", "\n");        -- space after newline code is useless
   end
	return retstr;
end

-------------------------------------------------------------------------------------------------------

-- the function appends spaces to the left of the given text so that the text is aligned to the right
function CH_AddSpaces(txt, snd)                                 -- snd = second or next line (interspace 2 on right)
   local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME:GetFont();     -- read current font, size and flag of the chat object
   local chars_limitC = 150;    -- so much max. characters can fit on one line
   
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

function CH_mysplit (inputstr, sep)
   if (sep == nil) then
      sep = "%s";
   end
   local t={};
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str);
   end
   return t;
end

-------------------------------------------------------------------------------------------------------

function CH_SpecifyBubbleWidth(str_txt, reg)
   local vlines = CH_mysplit(str_txt,"\n");
   local _fontR, _sizeR, _R = reg:GetFont();   -- odczytaj aktualną czcionkę i rozmiar
   local max_width = 20;
   for _, v in ipairs(vlines) do 
      if (CH_TestLine == nil) then     -- a own frame for displaying the translation of texts and determining the length
         CH_CreateTestLine();
      end   
      CH_TestLine:Hide();     -- the frame is invisible in the game
      CH_TestLine.text:SetFont(_fontR, _sizeR, _R);
      local newTextWidth = (0.35*act_font+0.8)*AS_UTF8len(v)*1.5;  -- maksymalna szerokość okna dymku
      CH_TestLine.text:SetWidth(newTextWidth);
      CH_TestLine.text:SetText(v);
      local minTextWidth = (0.35*act_font+0.8)*AS_UTF8len(v)*0.8;  -- minimalna szerokość ograniczająca pętlę
      
      while ((CH_TestLine.text:GetHeight() < _sizeR*1.5) and (minTextWidth < newTextWidth)) do
         newTextWidth = newTextWidth - 5;
         CH_TestLine.text:SetWidth(newTextWidth);
      end
      if (newTextWidth > max_width) then
         max_width = newTextWidth;
      end
   end
   return max_width + 5;
end

-------------------------------------------------------------------------------------------------------

-- Reverses the order of UTF-8 letters in (limit) lines: 2 or 3 
function CH_LineReverse(s, limit)
   local retstr = "";
   if (s and limit) then                           -- check if arguments are not empty (nil)
		local bytes = strlen(s);
      local count_chars = AS_UTF8len(s);           -- number of characters in a string s
      local limit_chars = count_chars / limit;     -- limit characters on one line (+-)
		local pos = 1;
		local charbytes;
		local newstr = "";
      local counter = 0;
      local char1;
		while pos <= bytes do
			c = strbyte(s, pos);                      -- read the character (odczytaj znak)
			charbytes = AS_UTF8charbytes(s, pos);    -- count of bytes (liczba bajtów znaku)
         char1 = strsub(s, pos, pos + charbytes - 1);
			newstr = newstr .. char1;
			pos = pos + charbytes;
         
         counter = counter + 1;
         if ((char1 >= "A") and (char1 <= "z")) then
            counter = counter + 1;        -- latin letters are 2x wider, then Arabic
         end
         if ((char1 == " ") and (counter>=limit_chars-3)) then      -- break line here
            retstr = retstr .. AS_UTF8reverse(newstr) .. "\n";
            newstr = "";
            counter = 0;
         end
      end
      retstr = retstr .. AS_UTF8reverse(newstr);
      retstr = string.gsub(retstr, "\n ", "\n");        -- space after newline code is useless
   end
	return retstr;
end 

-------------------------------------------------------------------------------------------------------

CH_Frame = CreateFrame("Frame");
CH_Frame:RegisterEvent("ADDON_LOADED");
CH_Frame:SetScript("OnEvent", CH_OnEvent);
