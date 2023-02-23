-- Arabic Reshaper for WoWinArabic addons (2023.02.22)
-- Author: Platine  (e-mail: platine.wow@gmail.com)
-- Based on UTF8 library by Kyle Smith
-- Special thanks to DragonArab for create letter reshaping tables and ligatures.

local debug_show_form = 0;

-- define a table of reshaping rules for Arabic characters
AS_Reshaping_Rules = {
   ["ا"] = {isolated = "ا", initial = "ا", middle = "ﺎ", final = "ﺎ"},-- ALEF
   ["ﺁ"] = {isolated = "ﺁ", initial = "ﺁ", middle = "ﺂ", final = "ﺂ"},-- ALEF WITH MADA ABOVE
   ["أ"] = {isolated = "أ", initial = "أ", middle = "ﺄ", final = "ﺄ"},-- ALEF WITH HAMZA ABOVE
   ["إ"] = {isolated = "إ", initial = "إ", middle = "ﺈ", final = "ﺈ"},-- ALEF WITH HAMZA BELOW
   ["ب"] = {isolated = "ب", initial = "ﺑ", middle = "ﺒ", final = "ﺐ"},-- BA
   ["ت"] = {isolated = "ت", initial = "ﺗ", middle = "ﺘ", final = "ﺖ"},-- TA
   ["ث"] = {isolated = "ث", initial = "ﺛ", middle = "ﺜ", final = "ﺚ"},-- THA
   ["ج"] = {isolated = "ج", initial = "ﺟ", middle = "ﺠ", final = "ﺞ"},-- JIM
   ["ح"] = {isolated = "ح", initial = "ﺣ", middle = "ﺤ", final = "ﺢ"},-- HAH
   ["خ"] = {isolated = "خ", initial = "ﺧ", middle = "ﺨ", final = "ﺦ"},-- KHAH
   ["د"] = {isolated = "د", initial = "د", middle = "ﺪ", final = "ﺪ"},-- DAL
   ["ذ"] = {isolated = "ذ", initial = "ذ", middle = "ﺬ", final = "ﺬ"},-- DHAL
   ["ر"] = {isolated = "ر", initial = "ر", middle = "ﺮ", final = "ﺮ"},-- RA
   ["ز"] = {isolated = "ز", initial = "ز", middle = "ﺰ", final = "ﺰ"},-- ZAIN
   ["س"] = {isolated = "س", initial = "ﺳ", middle = "ﺴ", final = "ﺲ"},-- SIN
   ["ش"] = {isolated = "ش", initial = "ﺷ", middle = "ﺸ", final = "ﺶ"},-- SHIN
   ["ص"] = {isolated = "ص", initial = "ﺻ", middle = "ﺼ", final = "ﺺ"},-- SAD
   ["ض"] = {isolated = "ض", initial = "ﺿ", middle = "ﻀ", final = "ﺾ"},-- DAD
   ["ط"] = {isolated = "ط", initial = "ﻃ", middle = "ﻂ", final = "ﻂ"},-- TAH
   ["ظ"] = {isolated = "ظ", initial = "ﻇ", middle = "ﻈ", final = "ﻆ"},-- ZAH
   ["ع"] = {isolated = "ع", initial = "ﻋ", middle = "ﻌ", final = "ﻊ"},-- AIN
   ["غ"] = {isolated = "غ", initial = "ﻏ", middle = "ﻐ", final = "ﻎ"},-- GHAIN
   ["ف"] = {isolated = "ف", initial = "ﻓ", middle = "ﻔ", final = "ﻒ"},-- FEH
   ["ق"] = {isolated = "ق", initial = "ﻗ", middle = "ﻘ", final = "ﻖ"},-- QAF
   ["ك"] = {isolated = "ك", initial = "ﻛ", middle = "ﻜ", final = "ﻚ"},-- KAF
   ["ل"] = {isolated = "ل", initial = "ﻟ", middle = "ﻠ", final = "ﻞ"},-- LAM
   ["م"] = {isolated = "م", initial = "ﻣ", middle = "ﻤ", final = "ﻢ"},-- MIM
   ["ن"] = {isolated = "ن", initial = "ﻧ", middle = "ﻨ", final = "ﻦ"},-- NUN
   ["ي"] = {isolated = "ي", initial = "ﻳ", middle = "ﻴ", final = "ﻲ"},-- YA
   ["ئ"] = {isolated = "ئ", initial = "ﺋ", middle = "ﺌ", final = "ﺊ"},-- YEH WITH HAMZA ABOVE
   ["ى"] = {isolated = "ى", initial = "ى", middle = "ى", final = "ﻰ"},-- ALEF MAKSURA
   ["و"] = {isolated = "و", initial = "و", middle = "ﻮ", final = "ﻮ"},-- WAW
   ["ؤ"] = {isolated = "ؤ", initial = "ﺆ", middle = "ﺆ", final = "ﺆ"},-- WAW WITH HAMZA ABOVE
   ["ه"] = {isolated = "ﻩ", initial = "ﻫ", middle = "ﻬ", final = "ﻪ"},-- HAH
   ["ة"] = {isolated = "ة", initial = "ة", middle = "ة", final = "ﺔ"},-- TAH
   ["ﻻ"] = {isolated = "ﻻ", initial = "ﻻ", middle = "ﻼ", final = "ﻼ"},-- LAM WITH ALEF
   ["ﻵ"] = {isolated = "ﻵ", initial = "ﻵ", middle = "ﻶ", final = "ﻶ"},-- LAM WITH ALEF WITH MADDA
   ["لأ"] = {isolated = "ﻷ", initial = "ﻷ", middle = "ﻸ", final = "ﻸ"},-- LAM WITH ALEF WITH HAMZA ABOVE
   ["لإ"] = {isolated = "ﻹ", initial = "ﻹ", middle = "ﻺ", final = "ﻺ"},-- LAM WITH ALEF WITH HAMZA BELOW
   ["ء"] = {isolated = "ء", initial = "ﺀ", middle = "ﺀ", final = "ﺀ"},-- HAMZA
   };

AS_Reshaping_Rules2 = {
   ["ل".."ا"] = {isolated = "ﻻ", initial="ﻻ",  middle="ﻼ",  final="ﻼ"},            -- Arabic ligature LAM with ALEF
   ["ل".."أ"] = {isolated = "ﻷ", initial="ﻷ",  middle="ﻸ",  final="ﻸ"},            -- Arabic ligature LAM with ALEF with HAMZA above
   ["ل".."إ"] = {isolated = "ﻹ", initial="ﻹ",  middle="ﻺ",  final="ﻺ"},            -- Arabic ligature LAM with ALEF with HAMZA below
   ["ل".."آ"] = {isolated = "ﻵ", initial="ﻵ",  middle="ﻶ",  final="ﻶ"},            -- Arabic ligature LAM with ALEF with MADDA
   --Test
   ["إ".."ع"] = {isolated = "0",    initial="ﻋإ",  middle="ﻋﺈ",   final="3"},           -- Arabic ligature ALEF with Hamaz below + AIN Middle
   ["ء".."و"] = {isolated = "وء",   initial="وء",  middle="وء",   final="وء"},
   ["ي".."ء"] = {isolated = "0",    initial="1",   middle="ءﻲ",   final="3"},        
   };

AS_Reshaping_Rules3 = {
   ["ا".."ل".."آ"] = {isolated = "ﻵا",  initial="ﻵا", middle="ﻵا", final="ﻶا"},        -- Arabic ligature ALEF+LAM+(ALEF with MADA)
   ["ا".."ل".."أ"] = {isolated = "ﻷا",  initial="ﻷا", middle="ﻷا", final="ﻸا"},        -- Arabic ligature ALEF+LAM+(ALEF with HAMZA)
   ["ا".."ل".."إ"] = {isolated = "ﻹا",  initial="ﻹا", middle="ﻹا", final="ﻺا"},        -- Arabic ligature ALEF+LAM+(ALEF with HAMZA Below)
   ["ا".."ل".."ا"] = {isolated = "ﻻا",  initial="ﻻا", middle="ﻻا", final="ﻼا"},        -- Arabic ligature ALEF+LAM+(ALEF with ALEF)
   ["ش".."ي".."ء"] = {isolated = "ءﻲﺷ",  initial="ءﻲﺷ", middle="ءﻲﺸ", final="ءﻲﺸ"},    -- Arabic ligature SHIN+YEH+HAMZA Below
   ["ل".."ا".."ز"] = {isolated = "زﻻ",  initial="زﻻ", middle="زﻼ", final="زﻼ"},        -- Arabic ligature LAM+ALEF+ZAIN
   };

-------------------------------------------------------------------------------------------------------

-- returns the number of bytes used by the UTF-8 character at byte
function AS_UTF8charbytes(s, i)
	-- argument defaults
	i = i or 1;

	-- argument checking
	if (type(s) ~= "string") then
		error("bad argument #1 to 'AS_UTF8charbytes' (string expected, got ".. type(s).. ")");
	end
	if (type(i) ~= "number") then
		error("bad argument #2 to 'QTR_UFT8charbytes' (number expected, got ".. type(i).. ")");
	end

	local c = strbyte(s, i);

	-- determine bytes needed for character, based on RFC 3629
	-- validate byte 1
	if (c > 0 and c <= 127) then
		-- UTF8-1
		return 1;

	elseif (c >= 194 and c <= 223) then
		-- UTF8-2
		local c2 = strbyte(s, i + 1);

		if (not c2) then
			error("UTF-8 string terminated early");
		end

		-- validate byte 2
		if (c2 < 128 or c2 > 191) then
			error("Invalid UTF-8 character");
		end

		return 2;

	elseif (c >= 224 and c <= 239) then
		-- UTF8-3
		local c2 = strbyte(s, i + 1);
		local c3 = strbyte(s, i + 2);

		if (not c2 or not c3) then
			error("UTF-8 string terminated early");
		end

		-- validate byte 2
		if (c == 224 and (c2 < 160 or c2 > 191)) then
			error("Invalid UTF-8 character")
		elseif (c == 237 and (c2 < 128 or c2 > 159)) then
			error("Invalid UTF-8 character");
		elseif (c2 < 128 or c2 > 191) then
			error("Invalid UTF-8 character");
		end

		-- validate byte 3
		if (c3 < 128 or c3 > 191) then
			error("Invalid UTF-8 character");
		end

		return 3;

	elseif (c >= 240 and c <= 244) then
		-- UTF8-4
		local c2 = strbyte(s, i + 1);
		local c3 = strbyte(s, i + 2);
		local c4 = strbyte(s, i + 3);

		if ((not c2) or (not c3) or (not c4)) then
			error("UTF-8 string terminated early");
		end

		-- validate byte 2
		if (c == 240 and (c2 < 144 or c2 > 191)) then
			error("Invalid UTF-8 character");
		elseif (c == 244 and (c2 < 128 or c2 > 143)) then
			error("Invalid UTF-8 character");
		elseif (c2 < 128 or c2 > 191) then
			error("Invalid UTF-8 character");
		end

		-- validate byte 3
		if (c3 < 128 or c3 > 191) then
			error("Invalid UTF-8 character");
		end

		-- validate byte 4
		if (c4 < 128 or c4 > 191) then
			error("Invalid UTF-8 character");
		end

		return 4;

	else
		error("Invalid UTF-8 character: "..c);
	end
end

-------------------------------------------------------------------------------------------------------

-- returns the number of characters in a UTF-8 string
function AS_UTF8len(s)
   local len = 0;
   if (s) then          -- argument checking
      local pos = 1;
      local bytes = strlen(s);
      while (pos <= bytes) do
         len = len + 1;
         pos = pos + AS_UTF8charbytes(s, pos);
      end
   end
   return len;
end

-------------------------------------------------------------------------------------------------------

-- function finding character c in the string s and return true or false
function AS_UTF8find(s, c)
   local odp = false;
   if (s and c) then                                   -- check if arguments are not empty (nil)
		local pos = 1;
		local bytes = strlen(s);                         -- number of length of the string s in bytes
      local charbytes;
      local char1;

		while (pos <= bytes) do
         charbytes = AS_UTF8charbytes(s, pos);         -- count of bytes of the character
         char1 = strsub(s, pos, pos + charbytes - 1);  -- current character from the string s
			if (char1 == c) then
            odp = true;
         end
			pos = pos + AS_UTF8charbytes(s, pos);
		end
   end
	return odp;
end

-------------------------------------------------------------------------------------------------------

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
function AS_UTF8sub(s, i, j)
	j = j or -1;            -- argument defaults, is not required

	-- argument checking
	if (type(s) ~= "string") then
		error("bad argument #1 to 'AS_UTF8sub' (string expected, got ".. type(s).. ")");
	end
	if (type(i) ~= "number") then
		error("bad argument #2 to 'AS_UTF8sub' (number expected, got ".. type(i).. ")");
	end
	if (type(j) ~= "number") then
		error("bad argument #3 to 'AS_UTF8sub' (number expected, got ".. type(j).. ")");
	end

	local pos = 1;
	local bytes = strlen(s);
	local len = 0;

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or AS_UTF8len(s);
	local startChar = (i >= 0) and i or l + i + 1;
	local endChar   = (j >= 0) and j or l + j + 1;

	-- can't have start before end!
	if (startChar > endChar) then
		return "";
	end

	-- byte offsets to pass to string.sub
	local startByte, endByte = 1, bytes;

	while (pos <= bytes) do
		len = len + 1;

		if (len == startChar) then
			startByte = pos;
		end

		pos = pos + AS_UTF8charbytes(s, pos);

		if (len == endChar) then
			endByte = pos - 1;
			break;
		end
	end

	return strsub(s, startByte, endByte);
end

-------------------------------------------------------------------------------------------------------

-- Reverses the order of UTF-8 letters with ReShaping
function AS_UTF8reverse(s)
   local newstr = "";
   if (s) then                                   -- check if argument is not empty (nil)
      local bytes = strlen(s);
      local pos = 1;
      local char0 = '';
      local char1, char2, char3;
      local charbytes1, charbytes2, charbytes3;
      local position = -1;           -- not specified
      local nextletter = 0;
      local spaces = '( )?؟!,.;:،';  -- letters that we treat as a space

      while (pos <= bytes) do
         charbytes1 = AS_UTF8charbytes(s, pos);        -- count of bytes (liczba bajtów znaku)
         char1 = strsub(s, pos, pos + charbytes1 - 1);  -- current character
			pos = pos + charbytes1;
         
         if (pos <= bytes) then
            charbytes2 = AS_UTF8charbytes(s, pos);        -- count of bytes (liczba bajtów znaku)
            char2 = strsub(s, pos, pos + charbytes2 - 1);  -- next character
            if (pos+charbytes2 <= bytes) then              -- 3rd next letter is available
               charbytes3 = AS_UTF8charbytes(s, pos+charbytes2);                   -- count of bytes (liczba bajtów znaku)
               char3 = strsub(s, pos+charbytes2, pos+charbytes2 + charbytes3 - 1);  -- 3rd next character
            else
               charbytes3 = 0;
               char3 = 'X';
            end
            
            if (AS_UTF8find(spaces,char2)) then
               nextletter = 1;      -- space, question mark, exclamation mark, comma, dot, etc.
            else
               nextletter = 2;      -- normal letter
            end
         else
            nextletter = 0;         -- no more letters
            char2 = 'X';
            char3 = 'X';
            charbytes2 = 0;
            charbytes3 = 0;
         end

         -- first determine the original position of the letter in the word
         if (AS_UTF8find(spaces,char1)) then
            position = -1;      -- space, question mark, exclamation mark, comma, dot, etc.
         elseif (position < 0) then        -- not specified yet (start the word)
            if ((nextletter == 0) or (nextletter == 1)) then    -- end of file or space on as a next letter
               position = 0;           -- isolated letter
            else
               position = 1;           -- initial letter
            end
         elseif ((position == 0) or (position == 1) or (position == 2)) then       -- it was isolated or initial or middle letter
            if ((nextletter == 0) or (nextletter == 1)) then    -- end of file or space on next letter
               position = 3;           -- final letter
            else
               if (position == 0) then    -- it was isolated letter
                  position = 1;           -- initial letter
               else
                  position = 2;           -- middle letter
               end
            end         
         else                             -- it was final letter (position == 3)
            position = -1;
         end

         -- now modifications to the form of the letter depending on the preceding special letters   
         if ((char0 == "ﻼ") or (char0 == "ﻸ") or (char0 == "ﻺ") or (char0 == "ﻶ") or (char0 == "ا") or (char0 == "أ") or (char0 == "إ") or (char0 == "آ") or (char0 == "لا") or (char0 == "ﻷ") or (char0 == "ﻹ") or (char0 == "ﻵ") or (char0 == "ﻵا") or (char0 == "ﻷا") or (char0 == "ﻹا") or (char0 == "ﻻا")) then    -- previous letter was ALEF, DA, THA, RA, ZAI, WA or LA, current should be in isolated form, only if this letter is the last in the word, otherwise form must be initial
            if (AS_UTF8find(spaces,char1)) then                                     -- current character is space
               position = 0;                                                        -- isolated letter
            elseif ((nextletter == 0) or (nextletter == 1)) then                    -- end of file or space on as a next letter OR letter is ALEF
               position = 0;      
            else
               position = 1;                                                        -- initial letter
            end
         elseif (char0 == "ذ") and (char1 == "ه") then                              -- previous letter was THA, current HA should be in isolated form, only if HA is the last in the word, otherwise form must be initial
            if ((nextletter == 0) or (nextletter == 1)) then                        -- end of file or space on as a next letter
               position = 0;                                                        -- isolated letter
            else
               position = 1;                                                        -- initial letter
            end
         elseif  (char0 == "د") or (char0 == "ذ") or (char0 == "ر") or (char0 == "ز") or (char0 == "و") or (char0 == "ؤ") then
            if (AS_UTF8find(spaces,char1)) then                                     -- current character is space
               position = 0;                                                        -- isolated letter
            elseif ((nextletter == 0) or (nextletter == 1)) then                    -- next character is space
               position = 0;                                                        -- isolated letter
            else
               position = 1;                                                        -- initial letter
            end
         end
         
         
         if ((AS_Reshaping_Rules3[char1..char2..char3]) and (position >= 0)) then  -- ligature 3 characters
            local ligature = AS_Reshaping_Rules3[char1..char2..char3];
            if (position == 0) then
               char1 = ligature.isolated;
            elseif (position == 1) then
               char1 = ligature.initial;
            elseif (position == 2) then
               char1 = ligature.middle;
            else
               char1 = ligature.final;
            end
            pos = pos + charbytes2 + charbytes3;    -- we omit the next preceding letters
         elseif ((AS_Reshaping_Rules2[char1..char2]) and (position >= 0)) then     -- ligature 2 characters
            local ligature = AS_Reshaping_Rules2[char1..char2];
            if (position == 0) then
               char1 = ligature.isolated;
            elseif (position == 1) then
               char1 = ligature.initial;
            elseif (position == 2) then
               char1 = ligature.middle;
            else
               char1 = ligature.final;
            end
            pos = pos + charbytes2;    -- we omit the next preceding letter
         end   
         

         -- check if the character has reshaping rules
         local rules = AS_Reshaping_Rules[char1];
         if (rules) then
            -- apply reshaping rules based on the character's position in the string
            if (position == 0) then       -- isolated letter
               if (debug_show_form == 1) then
                  newstr = '0'..rules.isolated .. newstr;
               else
                  newstr = rules.isolated .. newstr;
               end
            elseif (position == 1) then   -- initial letter
               if (debug_show_form == 1) then
                  newstr = '1'..rules.initial .. newstr;
               else
                  newstr = rules.initial .. newstr;
               end
            elseif (position == 2) then   -- middle letter
               if (debug_show_form == 1) then
                  newstr = '2'..rules.middle .. newstr;
               else
                  newstr = rules.middle .. newstr;
               end
            else                          -- final letter
               if (debug_show_form == 1) then
                  newstr = '3'..rules.final .. newstr;
               else
                  newstr = rules.final .. newstr;
               end
            end
         else  -- character has no reshaping rules, add it to the result string as is
            if (char1 == "<") then        -- we need to reverse the directions of the parentheses
               char1 = ">";
            elseif (char1 == ">") then
               char1 = "<";
            elseif (char1 == "(") then
               char1 = ")";
            elseif (char1 == ")") then
               char1 = "(";
            end
            if (debug_show_form == 1) then
               newstr = position..char1 .. newstr;
            else
               newstr = char1 .. newstr;
            end
         end
         char0 = char1;    --save to previous letter
      end
   end
   return newstr;
end

-------------------------------------------------------------------------------------------------------
