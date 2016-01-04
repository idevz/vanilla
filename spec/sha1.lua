--
-- SHA-1 secure hash computation, and HMAC-SHA1 signature computation,
-- in pure Lua (tested on Lua 5.1)
--
-- Latest version always at:  http://regex.info/blog/lua/sha1
--
-- Copyright 2009 Jeffrey Friedl
-- jfriedl@yahoo.com
-- http://regex.info/blog/
--
--
-- Version 1 [May 28, 2009]
--
--
-- Lua is a pathetic, horrid, turd of a language. Not only doesn't it have
-- bitwise integer operators like OR and AND, it doesn't even have integers
-- (and those, relatively speaking, are its good points). Yet, this
-- implements the SHA-1 digest hash in pure Lua. While coding it, I felt as
-- if I were chiseling NAND gates out of rough blocks of silicon. Those not
-- already familiar with this woeful language may, upon seeing this code,
-- throw up in their own mouth.
--
-- It's not super fast.... a 10k-byte message takes about 2 seconds on a
-- circa-2008 mid-level server, but it should be plenty adequate for short
-- messages, such as is often needed during authentication handshaking.
--
-- Algorithm: http://www.itl.nist.gov/fipspubs/fip180-1.htm
--
-- This file creates four entries in the global namespace:
--
--   local hash_as_hex   = sha1(message)            -- returns a hex string
--   local hash_as_data  = sha1_binary(message)     -- returns raw bytes
--
--   local hmac_as_hex   = hmac_sha1(key, message)        -- hex string
--   local hmac_as_data  = hmac_sha1_binary(key, message) -- raw bytes
--
-- Pass sha1() a string, and it returns a hash as a 40-character hex string.
-- For example, the call
--
--   local hash = sha1 "http://regex.info/blog/"
--
-- puts the 40-character string
--
--   "7f103bf600de51dfe91062300c14738b32725db5"
--
-- into the variable 'hash'
--
-- Pass sha1_hmac() a key and a message, and it returns the signature as a
-- 40-byte hex string.
--
--
-- The two "_binary" versions do the same, but return the 20-byte string of raw data
-- that the 40-byte hex strings represent.
--

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


--
-- Return a W32 object for the number zero
--
local function ZERO()
   return {
      false, false, false, false,     false, false, false, false,
      false, false, false, false,     false, false, false, false,
      false, false, false, false,     false, false, false, false,
      false, false, false, false,     false, false, false, false,
   }
end

local hex_to_bits = {
   ["0"] = { false, false, false, false },
   ["1"] = { false, false, false, true  },
   ["2"] = { false, false, true,  false },
   ["3"] = { false, false, true,  true  },

   ["4"] = { false, true,  false, false },
   ["5"] = { false, true,  false, true  },
   ["6"] = { false, true,  true,  false },
   ["7"] = { false, true,  true,  true  },

   ["8"] = { true,  false, false, false },
   ["9"] = { true,  false, false, true  },
   ["A"] = { true,  false, true,  false },
   ["B"] = { true,  false, true,  true  },

   ["C"] = { true,  true,  false, false },
   ["D"] = { true,  true,  false, true  },
   ["E"] = { true,  true,  true,  false },
   ["F"] = { true,  true,  true,  true  },

   ["a"] = { true,  false, true,  false },
   ["b"] = { true,  false, true,  true  },
   ["c"] = { true,  true,  false, false },
   ["d"] = { true,  true,  false, true  },
   ["e"] = { true,  true,  true,  false },
   ["f"] = { true,  true,  true,  true  },
}

--
-- Given a string of 8 hex digits, return a W32 object representing that number
--
local function from_hex(hex)

   assert(type(hex) == 'string')
   assert(hex:match('^[0123456789abcdefABCDEF]+$'))
   assert(#hex == 8)

   local W32 = { }

   for letter in hex:gmatch('.') do
      local b = hex_to_bits[letter]
      assert(b)
      table.insert(W32, 1, b[1])
      table.insert(W32, 1, b[2])
      table.insert(W32, 1, b[3])
      table.insert(W32, 1, b[4])
   end

   return W32
end

local function COPY(old)
   local W32 = { }
   for k,v in pairs(old) do
      W32[k] = v
   end

   return W32
end

local function ADD(first, ...)

   local a = COPY(first)

   local C, b, sum

   for v = 1, select('#', ...) do
      b = select(v, ...)
      C = 0

      for i = 1, #a do
         sum = (a[i] and 1 or 0)
             + (b[i] and 1 or 0)
             + C

         if sum == 0 then
            a[i] = false
            C    = 0
         elseif sum == 1 then
            a[i] = true
            C    = 0
         elseif sum == 2 then
            a[i] = false
            C    = 1
         else
            a[i] = true
            C    = 1
         end
      end
      -- we drop any ending carry

   end

   return a
end

local function XOR(first, ...)

   local a = COPY(first)
   local b
   for v = 1, select('#', ...) do
      b = select(v, ...)
      for i = 1, #a do
         a[i] = a[i] ~= b[i]
      end
   end

   return a

end

local function AND(a, b)

   local c = ZERO()

   for i = 1, #a do
      -- only need to set true bits; other bits remain false
      if  a[i] and b[i] then
         c[i] = true
      end
   end

   return c
end

local function OR(a, b)

   local c = ZERO()

   for i = 1, #a do
      -- only need to set true bits; other bits remain false
      if  a[i] or b[i] then
         c[i] = true
      end
   end

   return c
end

local function OR3(a, b, c)

   local d = ZERO()

   for i = 1, #a do
      -- only need to set true bits; other bits remain false
      if a[i] or b[i] or c[i] then
         d[i] = true
      end
   end

   return d
end

local function NOT(a)

   local b = ZERO()

   for i = 1, #a do
      -- only need to set true bits; other bits remain false
      if not a[i] then
         b[i] = true
      end
   end

   return b
end

local function ROTATE(bits, a)

   local b = COPY(a)

   while bits > 0 do
      bits = bits - 1
      table.insert(b, 1, table.remove(b))
   end

   return b

end


local binary_to_hex = {
   ["0000"] = "0",
   ["0001"] = "1",
   ["0010"] = "2",
   ["0011"] = "3",
   ["0100"] = "4",
   ["0101"] = "5",
   ["0110"] = "6",
   ["0111"] = "7",
   ["1000"] = "8",
   ["1001"] = "9",
   ["1010"] = "a",
   ["1011"] = "b",
   ["1100"] = "c",
   ["1101"] = "d",
   ["1110"] = "e",
   ["1111"] = "f",
}

local sha1 = {}

function sha1.asHEX(a)

   local hex = ""
   local i = 1
   while i < #a do
      local binary = (a[i + 3] and '1' or '0')
                     ..
                     (a[i + 2] and '1' or '0')
                     ..
                     (a[i + 1] and '1' or '0')
                     ..
                     (a[i + 0] and '1' or '0')

      hex = binary_to_hex[binary] .. hex

      i = i + 4
   end

   return hex

end

local x67452301 = from_hex("67452301")
local xEFCDAB89 = from_hex("EFCDAB89")
local x98BADCFE = from_hex("98BADCFE")
local x10325476 = from_hex("10325476")
local xC3D2E1F0 = from_hex("C3D2E1F0")

local x5A827999 = from_hex("5A827999")
local x6ED9EBA1 = from_hex("6ED9EBA1")
local x8F1BBCDC = from_hex("8F1BBCDC")
local xCA62C1D6 = from_hex("CA62C1D6")


function sha1.sha1(msg)

   assert(type(msg) == 'string')
   assert(#msg < 0x7FFFFFFF) -- have no idea what would happen if it were large

   local H0 = x67452301
   local H1 = xEFCDAB89
   local H2 = x98BADCFE
   local H3 = x10325476
   local H4 = xC3D2E1F0

   local msg_len_in_bits = #msg * 8

   local first_append = string.char(0x80) -- append a '1' bit plus seven '0' bits

   local non_zero_message_bytes = #msg +1 +8 -- the +1 is the appended bit 1, the +8 are for the final appended length
   local current_mod = non_zero_message_bytes % 64
   local second_append = ""
   if current_mod ~= 0 then
      second_append = string.rep(string.char(0), 64 - current_mod)
   end

   -- now to append the length as a 64-bit number.
   local B1, R1 = math.modf(msg_len_in_bits  / 0x01000000)
   local B2, R2 = math.modf( 0x01000000 * R1 / 0x00010000)
   local B3, R3 = math.modf( 0x00010000 * R2 / 0x00000100)
   local B4     =            0x00000100 * R3

   local L64 = string.char( 0) .. string.char( 0) .. string.char( 0) .. string.char( 0) -- high 32 bits
            .. string.char(B1) .. string.char(B2) .. string.char(B3) .. string.char(B4) --  low 32 bits



   msg = msg .. first_append .. second_append .. L64

   assert(#msg % 64 == 0)

   --local fd = io.open("/tmp/msg", "wb")
   --fd:write(msg)
   --fd:close()

   local chunks = #msg / 64

   local W = { }
   local start, A, B, C, D, E, f, K, TEMP
   local chunk = 0

   while chunk < chunks do
      --
      -- break chunk up into W[0] through W[15]
      --
      start = chunk * 64 + 1
      chunk = chunk + 1

      for t = 0, 15 do
         W[t] = from_hex(string.format("%02x%02x%02x%02x", msg:byte(start, start + 3)))
         start = start + 4
      end

      --
      -- build W[16] through W[79]
      --
      for t = 16, 79 do
         -- For t = 16 to 79 let Wt = S1(Wt-3 XOR Wt-8 XOR Wt-14 XOR Wt-16).
         W[t] = ROTATE(1, XOR(W[t-3], W[t-8], W[t-14], W[t-16]))
      end

      A = H0
      B = H1
      C = H2
      D = H3
      E = H4

      for t = 0, 79 do
         if t <= 19 then
            -- (B AND C) OR ((NOT B) AND D)
            f = OR(AND(B, C), AND(NOT(B), D))
            K = x5A827999
         elseif t <= 39 then
            -- B XOR C XOR D
            f = XOR(B, C, D)
            K = x6ED9EBA1
         elseif t <= 59 then
            -- (B AND C) OR (B AND D) OR (C AND D
            f = OR3(AND(B, C), AND(B, D), AND(C, D))
            K = x8F1BBCDC
         else
            -- B XOR C XOR D
            f = XOR(B, C, D)
            K = xCA62C1D6
         end

         -- TEMP = S5(A) + ft(B,C,D) + E + Wt + Kt;
         TEMP = ADD(ROTATE(5, A), f, E, W[t], K)

         --E = D; 　　D = C; 　　　C = S30(B);　　 B = A; 　　A = TEMP;
         E = D
         D = C
         C = ROTATE(30, B)
         B = A
         A = TEMP

         --printf("t = %2d: %s  %s  %s  %s  %s", t, A:HEX(), B:HEX(), C:HEX(), D:HEX(), E:HEX())
      end

      -- Let H0 = H0 + A, H1 = H1 + B, H2 = H2 + C, H3 = H3 + D, H4 = H4 + E.
      H0 = ADD(H0, A)
      H1 = ADD(H1, B)
      H2 = ADD(H2, C)
      H3 = ADD(H3, D)
      H4 = ADD(H4, E)
   end

   return sha1.asHEX(H0) .. sha1.asHEX(H1) .. sha1.asHEX(H2) .. sha1.asHEX(H3) .. sha1.asHEX(H4)
end

local function hex_to_binary(hex)
   return hex:gsub('..', function(hexval)
                            return string.char(tonumber(hexval, 16))
                         end)
end

function sha1.sha1_binary(msg)
   return hex_to_binary(sha1.sha1(msg))
end

local xor_with_0x5c = {
   [string.char(  0)] = string.char( 92),   [string.char(  1)] = string.char( 93),
   [string.char(  2)] = string.char( 94),   [string.char(  3)] = string.char( 95),
   [string.char(  4)] = string.char( 88),   [string.char(  5)] = string.char( 89),
   [string.char(  6)] = string.char( 90),   [string.char(  7)] = string.char( 91),
   [string.char(  8)] = string.char( 84),   [string.char(  9)] = string.char( 85),
   [string.char( 10)] = string.char( 86),   [string.char( 11)] = string.char( 87),
   [string.char( 12)] = string.char( 80),   [string.char( 13)] = string.char( 81),
   [string.char( 14)] = string.char( 82),   [string.char( 15)] = string.char( 83),
   [string.char( 16)] = string.char( 76),   [string.char( 17)] = string.char( 77),
   [string.char( 18)] = string.char( 78),   [string.char( 19)] = string.char( 79),
   [string.char( 20)] = string.char( 72),   [string.char( 21)] = string.char( 73),
   [string.char( 22)] = string.char( 74),   [string.char( 23)] = string.char( 75),
   [string.char( 24)] = string.char( 68),   [string.char( 25)] = string.char( 69),
   [string.char( 26)] = string.char( 70),   [string.char( 27)] = string.char( 71),
   [string.char( 28)] = string.char( 64),   [string.char( 29)] = string.char( 65),
   [string.char( 30)] = string.char( 66),   [string.char( 31)] = string.char( 67),
   [string.char( 32)] = string.char(124),   [string.char( 33)] = string.char(125),
   [string.char( 34)] = string.char(126),   [string.char( 35)] = string.char(127),
   [string.char( 36)] = string.char(120),   [string.char( 37)] = string.char(121),
   [string.char( 38)] = string.char(122),   [string.char( 39)] = string.char(123),
   [string.char( 40)] = string.char(116),   [string.char( 41)] = string.char(117),
   [string.char( 42)] = string.char(118),   [string.char( 43)] = string.char(119),
   [string.char( 44)] = string.char(112),   [string.char( 45)] = string.char(113),
   [string.char( 46)] = string.char(114),   [string.char( 47)] = string.char(115),
   [string.char( 48)] = string.char(108),   [string.char( 49)] = string.char(109),
   [string.char( 50)] = string.char(110),   [string.char( 51)] = string.char(111),
   [string.char( 52)] = string.char(104),   [string.char( 53)] = string.char(105),
   [string.char( 54)] = string.char(106),   [string.char( 55)] = string.char(107),
   [string.char( 56)] = string.char(100),   [string.char( 57)] = string.char(101),
   [string.char( 58)] = string.char(102),   [string.char( 59)] = string.char(103),
   [string.char( 60)] = string.char( 96),   [string.char( 61)] = string.char( 97),
   [string.char( 62)] = string.char( 98),   [string.char( 63)] = string.char( 99),
   [string.char( 64)] = string.char( 28),   [string.char( 65)] = string.char( 29),
   [string.char( 66)] = string.char( 30),   [string.char( 67)] = string.char( 31),
   [string.char( 68)] = string.char( 24),   [string.char( 69)] = string.char( 25),
   [string.char( 70)] = string.char( 26),   [string.char( 71)] = string.char( 27),
   [string.char( 72)] = string.char( 20),   [string.char( 73)] = string.char( 21),
   [string.char( 74)] = string.char( 22),   [string.char( 75)] = string.char( 23),
   [string.char( 76)] = string.char( 16),   [string.char( 77)] = string.char( 17),
   [string.char( 78)] = string.char( 18),   [string.char( 79)] = string.char( 19),
   [string.char( 80)] = string.char( 12),   [string.char( 81)] = string.char( 13),
   [string.char( 82)] = string.char( 14),   [string.char( 83)] = string.char( 15),
   [string.char( 84)] = string.char(  8),   [string.char( 85)] = string.char(  9),
   [string.char( 86)] = string.char( 10),   [string.char( 87)] = string.char( 11),
   [string.char( 88)] = string.char(  4),   [string.char( 89)] = string.char(  5),
   [string.char( 90)] = string.char(  6),   [string.char( 91)] = string.char(  7),
   [string.char( 92)] = string.char(  0),   [string.char( 93)] = string.char(  1),
   [string.char( 94)] = string.char(  2),   [string.char( 95)] = string.char(  3),
   [string.char( 96)] = string.char( 60),   [string.char( 97)] = string.char( 61),
   [string.char( 98)] = string.char( 62),   [string.char( 99)] = string.char( 63),
   [string.char(100)] = string.char( 56),   [string.char(101)] = string.char( 57),
   [string.char(102)] = string.char( 58),   [string.char(103)] = string.char( 59),
   [string.char(104)] = string.char( 52),   [string.char(105)] = string.char( 53),
   [string.char(106)] = string.char( 54),   [string.char(107)] = string.char( 55),
   [string.char(108)] = string.char( 48),   [string.char(109)] = string.char( 49),
   [string.char(110)] = string.char( 50),   [string.char(111)] = string.char( 51),
   [string.char(112)] = string.char( 44),   [string.char(113)] = string.char( 45),
   [string.char(114)] = string.char( 46),   [string.char(115)] = string.char( 47),
   [string.char(116)] = string.char( 40),   [string.char(117)] = string.char( 41),
   [string.char(118)] = string.char( 42),   [string.char(119)] = string.char( 43),
   [string.char(120)] = string.char( 36),   [string.char(121)] = string.char( 37),
   [string.char(122)] = string.char( 38),   [string.char(123)] = string.char( 39),
   [string.char(124)] = string.char( 32),   [string.char(125)] = string.char( 33),
   [string.char(126)] = string.char( 34),   [string.char(127)] = string.char( 35),
   [string.char(128)] = string.char(220),   [string.char(129)] = string.char(221),
   [string.char(130)] = string.char(222),   [string.char(131)] = string.char(223),
   [string.char(132)] = string.char(216),   [string.char(133)] = string.char(217),
   [string.char(134)] = string.char(218),   [string.char(135)] = string.char(219),
   [string.char(136)] = string.char(212),   [string.char(137)] = string.char(213),
   [string.char(138)] = string.char(214),   [string.char(139)] = string.char(215),
   [string.char(140)] = string.char(208),   [string.char(141)] = string.char(209),
   [string.char(142)] = string.char(210),   [string.char(143)] = string.char(211),
   [string.char(144)] = string.char(204),   [string.char(145)] = string.char(205),
   [string.char(146)] = string.char(206),   [string.char(147)] = string.char(207),
   [string.char(148)] = string.char(200),   [string.char(149)] = string.char(201),
   [string.char(150)] = string.char(202),   [string.char(151)] = string.char(203),
   [string.char(152)] = string.char(196),   [string.char(153)] = string.char(197),
   [string.char(154)] = string.char(198),   [string.char(155)] = string.char(199),
   [string.char(156)] = string.char(192),   [string.char(157)] = string.char(193),
   [string.char(158)] = string.char(194),   [string.char(159)] = string.char(195),
   [string.char(160)] = string.char(252),   [string.char(161)] = string.char(253),
   [string.char(162)] = string.char(254),   [string.char(163)] = string.char(255),
   [string.char(164)] = string.char(248),   [string.char(165)] = string.char(249),
   [string.char(166)] = string.char(250),   [string.char(167)] = string.char(251),
   [string.char(168)] = string.char(244),   [string.char(169)] = string.char(245),
   [string.char(170)] = string.char(246),   [string.char(171)] = string.char(247),
   [string.char(172)] = string.char(240),   [string.char(173)] = string.char(241),
   [string.char(174)] = string.char(242),   [string.char(175)] = string.char(243),
   [string.char(176)] = string.char(236),   [string.char(177)] = string.char(237),
   [string.char(178)] = string.char(238),   [string.char(179)] = string.char(239),
   [string.char(180)] = string.char(232),   [string.char(181)] = string.char(233),
   [string.char(182)] = string.char(234),   [string.char(183)] = string.char(235),
   [string.char(184)] = string.char(228),   [string.char(185)] = string.char(229),
   [string.char(186)] = string.char(230),   [string.char(187)] = string.char(231),
   [string.char(188)] = string.char(224),   [string.char(189)] = string.char(225),
   [string.char(190)] = string.char(226),   [string.char(191)] = string.char(227),
   [string.char(192)] = string.char(156),   [string.char(193)] = string.char(157),
   [string.char(194)] = string.char(158),   [string.char(195)] = string.char(159),
   [string.char(196)] = string.char(152),   [string.char(197)] = string.char(153),
   [string.char(198)] = string.char(154),   [string.char(199)] = string.char(155),
   [string.char(200)] = string.char(148),   [string.char(201)] = string.char(149),
   [string.char(202)] = string.char(150),   [string.char(203)] = string.char(151),
   [string.char(204)] = string.char(144),   [string.char(205)] = string.char(145),
   [string.char(206)] = string.char(146),   [string.char(207)] = string.char(147),
   [string.char(208)] = string.char(140),   [string.char(209)] = string.char(141),
   [string.char(210)] = string.char(142),   [string.char(211)] = string.char(143),
   [string.char(212)] = string.char(136),   [string.char(213)] = string.char(137),
   [string.char(214)] = string.char(138),   [string.char(215)] = string.char(139),
   [string.char(216)] = string.char(132),   [string.char(217)] = string.char(133),
   [string.char(218)] = string.char(134),   [string.char(219)] = string.char(135),
   [string.char(220)] = string.char(128),   [string.char(221)] = string.char(129),
   [string.char(222)] = string.char(130),   [string.char(223)] = string.char(131),
   [string.char(224)] = string.char(188),   [string.char(225)] = string.char(189),
   [string.char(226)] = string.char(190),   [string.char(227)] = string.char(191),
   [string.char(228)] = string.char(184),   [string.char(229)] = string.char(185),
   [string.char(230)] = string.char(186),   [string.char(231)] = string.char(187),
   [string.char(232)] = string.char(180),   [string.char(233)] = string.char(181),
   [string.char(234)] = string.char(182),   [string.char(235)] = string.char(183),
   [string.char(236)] = string.char(176),   [string.char(237)] = string.char(177),
   [string.char(238)] = string.char(178),   [string.char(239)] = string.char(179),
   [string.char(240)] = string.char(172),   [string.char(241)] = string.char(173),
   [string.char(242)] = string.char(174),   [string.char(243)] = string.char(175),
   [string.char(244)] = string.char(168),   [string.char(245)] = string.char(169),
   [string.char(246)] = string.char(170),   [string.char(247)] = string.char(171),
   [string.char(248)] = string.char(164),   [string.char(249)] = string.char(165),
   [string.char(250)] = string.char(166),   [string.char(251)] = string.char(167),
   [string.char(252)] = string.char(160),   [string.char(253)] = string.char(161),
   [string.char(254)] = string.char(162),   [string.char(255)] = string.char(163),
}

local xor_with_0x36 = {
   [string.char(  0)] = string.char( 54),   [string.char(  1)] = string.char( 55),
   [string.char(  2)] = string.char( 52),   [string.char(  3)] = string.char( 53),
   [string.char(  4)] = string.char( 50),   [string.char(  5)] = string.char( 51),
   [string.char(  6)] = string.char( 48),   [string.char(  7)] = string.char( 49),
   [string.char(  8)] = string.char( 62),   [string.char(  9)] = string.char( 63),
   [string.char( 10)] = string.char( 60),   [string.char( 11)] = string.char( 61),
   [string.char( 12)] = string.char( 58),   [string.char( 13)] = string.char( 59),
   [string.char( 14)] = string.char( 56),   [string.char( 15)] = string.char( 57),
   [string.char( 16)] = string.char( 38),   [string.char( 17)] = string.char( 39),
   [string.char( 18)] = string.char( 36),   [string.char( 19)] = string.char( 37),
   [string.char( 20)] = string.char( 34),   [string.char( 21)] = string.char( 35),
   [string.char( 22)] = string.char( 32),   [string.char( 23)] = string.char( 33),
   [string.char( 24)] = string.char( 46),   [string.char( 25)] = string.char( 47),
   [string.char( 26)] = string.char( 44),   [string.char( 27)] = string.char( 45),
   [string.char( 28)] = string.char( 42),   [string.char( 29)] = string.char( 43),
   [string.char( 30)] = string.char( 40),   [string.char( 31)] = string.char( 41),
   [string.char( 32)] = string.char( 22),   [string.char( 33)] = string.char( 23),
   [string.char( 34)] = string.char( 20),   [string.char( 35)] = string.char( 21),
   [string.char( 36)] = string.char( 18),   [string.char( 37)] = string.char( 19),
   [string.char( 38)] = string.char( 16),   [string.char( 39)] = string.char( 17),
   [string.char( 40)] = string.char( 30),   [string.char( 41)] = string.char( 31),
   [string.char( 42)] = string.char( 28),   [string.char( 43)] = string.char( 29),
   [string.char( 44)] = string.char( 26),   [string.char( 45)] = string.char( 27),
   [string.char( 46)] = string.char( 24),   [string.char( 47)] = string.char( 25),
   [string.char( 48)] = string.char(  6),   [string.char( 49)] = string.char(  7),
   [string.char( 50)] = string.char(  4),   [string.char( 51)] = string.char(  5),
   [string.char( 52)] = string.char(  2),   [string.char( 53)] = string.char(  3),
   [string.char( 54)] = string.char(  0),   [string.char( 55)] = string.char(  1),
   [string.char( 56)] = string.char( 14),   [string.char( 57)] = string.char( 15),
   [string.char( 58)] = string.char( 12),   [string.char( 59)] = string.char( 13),
   [string.char( 60)] = string.char( 10),   [string.char( 61)] = string.char( 11),
   [string.char( 62)] = string.char(  8),   [string.char( 63)] = string.char(  9),
   [string.char( 64)] = string.char(118),   [string.char( 65)] = string.char(119),
   [string.char( 66)] = string.char(116),   [string.char( 67)] = string.char(117),
   [string.char( 68)] = string.char(114),   [string.char( 69)] = string.char(115),
   [string.char( 70)] = string.char(112),   [string.char( 71)] = string.char(113),
   [string.char( 72)] = string.char(126),   [string.char( 73)] = string.char(127),
   [string.char( 74)] = string.char(124),   [string.char( 75)] = string.char(125),
   [string.char( 76)] = string.char(122),   [string.char( 77)] = string.char(123),
   [string.char( 78)] = string.char(120),   [string.char( 79)] = string.char(121),
   [string.char( 80)] = string.char(102),   [string.char( 81)] = string.char(103),
   [string.char( 82)] = string.char(100),   [string.char( 83)] = string.char(101),
   [string.char( 84)] = string.char( 98),   [string.char( 85)] = string.char( 99),
   [string.char( 86)] = string.char( 96),   [string.char( 87)] = string.char( 97),
   [string.char( 88)] = string.char(110),   [string.char( 89)] = string.char(111),
   [string.char( 90)] = string.char(108),   [string.char( 91)] = string.char(109),
   [string.char( 92)] = string.char(106),   [string.char( 93)] = string.char(107),
   [string.char( 94)] = string.char(104),   [string.char( 95)] = string.char(105),
   [string.char( 96)] = string.char( 86),   [string.char( 97)] = string.char( 87),
   [string.char( 98)] = string.char( 84),   [string.char( 99)] = string.char( 85),
   [string.char(100)] = string.char( 82),   [string.char(101)] = string.char( 83),
   [string.char(102)] = string.char( 80),   [string.char(103)] = string.char( 81),
   [string.char(104)] = string.char( 94),   [string.char(105)] = string.char( 95),
   [string.char(106)] = string.char( 92),   [string.char(107)] = string.char( 93),
   [string.char(108)] = string.char( 90),   [string.char(109)] = string.char( 91),
   [string.char(110)] = string.char( 88),   [string.char(111)] = string.char( 89),
   [string.char(112)] = string.char( 70),   [string.char(113)] = string.char( 71),
   [string.char(114)] = string.char( 68),   [string.char(115)] = string.char( 69),
   [string.char(116)] = string.char( 66),   [string.char(117)] = string.char( 67),
   [string.char(118)] = string.char( 64),   [string.char(119)] = string.char( 65),
   [string.char(120)] = string.char( 78),   [string.char(121)] = string.char( 79),
   [string.char(122)] = string.char( 76),   [string.char(123)] = string.char( 77),
   [string.char(124)] = string.char( 74),   [string.char(125)] = string.char( 75),
   [string.char(126)] = string.char( 72),   [string.char(127)] = string.char( 73),
   [string.char(128)] = string.char(182),   [string.char(129)] = string.char(183),
   [string.char(130)] = string.char(180),   [string.char(131)] = string.char(181),
   [string.char(132)] = string.char(178),   [string.char(133)] = string.char(179),
   [string.char(134)] = string.char(176),   [string.char(135)] = string.char(177),
   [string.char(136)] = string.char(190),   [string.char(137)] = string.char(191),
   [string.char(138)] = string.char(188),   [string.char(139)] = string.char(189),
   [string.char(140)] = string.char(186),   [string.char(141)] = string.char(187),
   [string.char(142)] = string.char(184),   [string.char(143)] = string.char(185),
   [string.char(144)] = string.char(166),   [string.char(145)] = string.char(167),
   [string.char(146)] = string.char(164),   [string.char(147)] = string.char(165),
   [string.char(148)] = string.char(162),   [string.char(149)] = string.char(163),
   [string.char(150)] = string.char(160),   [string.char(151)] = string.char(161),
   [string.char(152)] = string.char(174),   [string.char(153)] = string.char(175),
   [string.char(154)] = string.char(172),   [string.char(155)] = string.char(173),
   [string.char(156)] = string.char(170),   [string.char(157)] = string.char(171),
   [string.char(158)] = string.char(168),   [string.char(159)] = string.char(169),
   [string.char(160)] = string.char(150),   [string.char(161)] = string.char(151),
   [string.char(162)] = string.char(148),   [string.char(163)] = string.char(149),
   [string.char(164)] = string.char(146),   [string.char(165)] = string.char(147),
   [string.char(166)] = string.char(144),   [string.char(167)] = string.char(145),
   [string.char(168)] = string.char(158),   [string.char(169)] = string.char(159),
   [string.char(170)] = string.char(156),   [string.char(171)] = string.char(157),
   [string.char(172)] = string.char(154),   [string.char(173)] = string.char(155),
   [string.char(174)] = string.char(152),   [string.char(175)] = string.char(153),
   [string.char(176)] = string.char(134),   [string.char(177)] = string.char(135),
   [string.char(178)] = string.char(132),   [string.char(179)] = string.char(133),
   [string.char(180)] = string.char(130),   [string.char(181)] = string.char(131),
   [string.char(182)] = string.char(128),   [string.char(183)] = string.char(129),
   [string.char(184)] = string.char(142),   [string.char(185)] = string.char(143),
   [string.char(186)] = string.char(140),   [string.char(187)] = string.char(141),
   [string.char(188)] = string.char(138),   [string.char(189)] = string.char(139),
   [string.char(190)] = string.char(136),   [string.char(191)] = string.char(137),
   [string.char(192)] = string.char(246),   [string.char(193)] = string.char(247),
   [string.char(194)] = string.char(244),   [string.char(195)] = string.char(245),
   [string.char(196)] = string.char(242),   [string.char(197)] = string.char(243),
   [string.char(198)] = string.char(240),   [string.char(199)] = string.char(241),
   [string.char(200)] = string.char(254),   [string.char(201)] = string.char(255),
   [string.char(202)] = string.char(252),   [string.char(203)] = string.char(253),
   [string.char(204)] = string.char(250),   [string.char(205)] = string.char(251),
   [string.char(206)] = string.char(248),   [string.char(207)] = string.char(249),
   [string.char(208)] = string.char(230),   [string.char(209)] = string.char(231),
   [string.char(210)] = string.char(228),   [string.char(211)] = string.char(229),
   [string.char(212)] = string.char(226),   [string.char(213)] = string.char(227),
   [string.char(214)] = string.char(224),   [string.char(215)] = string.char(225),
   [string.char(216)] = string.char(238),   [string.char(217)] = string.char(239),
   [string.char(218)] = string.char(236),   [string.char(219)] = string.char(237),
   [string.char(220)] = string.char(234),   [string.char(221)] = string.char(235),
   [string.char(222)] = string.char(232),   [string.char(223)] = string.char(233),
   [string.char(224)] = string.char(214),   [string.char(225)] = string.char(215),
   [string.char(226)] = string.char(212),   [string.char(227)] = string.char(213),
   [string.char(228)] = string.char(210),   [string.char(229)] = string.char(211),
   [string.char(230)] = string.char(208),   [string.char(231)] = string.char(209),
   [string.char(232)] = string.char(222),   [string.char(233)] = string.char(223),
   [string.char(234)] = string.char(220),   [string.char(235)] = string.char(221),
   [string.char(236)] = string.char(218),   [string.char(237)] = string.char(219),
   [string.char(238)] = string.char(216),   [string.char(239)] = string.char(217),
   [string.char(240)] = string.char(198),   [string.char(241)] = string.char(199),
   [string.char(242)] = string.char(196),   [string.char(243)] = string.char(197),
   [string.char(244)] = string.char(194),   [string.char(245)] = string.char(195),
   [string.char(246)] = string.char(192),   [string.char(247)] = string.char(193),
   [string.char(248)] = string.char(206),   [string.char(249)] = string.char(207),
   [string.char(250)] = string.char(204),   [string.char(251)] = string.char(205),
   [string.char(252)] = string.char(202),   [string.char(253)] = string.char(203),
   [string.char(254)] = string.char(200),   [string.char(255)] = string.char(201),
}


local blocksize = 64 -- 512 bits

function sha1.hmac_sha1(key, text)
   assert(type(key)  == 'string', "key passed to hmac_sha1 should be a string")
   assert(type(text) == 'string', "text passed to hmac_sha1 should be a string")

   if #key > blocksize then
      key = sha1.sha1_binary(key)
   end

   local key_xord_with_0x36 = key:gsub('.', xor_with_0x36) .. string.rep(string.char(0x36), blocksize - #key)
   local key_xord_with_0x5c = key:gsub('.', xor_with_0x5c) .. string.rep(string.char(0x5c), blocksize - #key)

   return sha1.sha1(key_xord_with_0x5c .. sha1.sha1_binary(key_xord_with_0x36 .. text))
end

function sha1.hmac_sha1_binary(key, text)
   return hex_to_binary(sha1.hmac_sha1(key, text))
end

return sha1
