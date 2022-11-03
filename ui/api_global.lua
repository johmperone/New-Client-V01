include "ui/http_event_register_define.lua"
-- 0 ����
-- 1 ����
-- 2 ���
-- 3 �ٻ�
-- 4 ����
local PartyInfoList =
{
	[1] =
	{
		["Name"] = "$L:1159$",
	};
	[2] =
	{
		["Name"] = "$L:1158$",
	};
	[3] =
	{
		["Name"] = "$L:1160$",
	};
	[4] =
	{
		["Name"] = "$L:1161$",
	};
	[5] =
	{
		["Name"] = "$L:1162$",
	};
};

--=========================  EvUiLuaClass�ĸ�����������  =========================
function EvUiLuaClassAssistant_SetSuperClass(self, super)
	if not self then return end
	if super then
		setmetatable(self, super);
		super.__index = super;
	end
end
--=========================  RichText�ĸ�����������  =========================
function EvUiLuaRichTextAssistant_ToRichTextString(self, tagname, attribute_list, child_list)
	local str = "<"..tagname;
	if attribute_list then
		for k, v in pairs(attribute_list) do
			if self[v] then
				local value = nil;
				if type(self[v]) == "table" then
					value = self[v]:ToRichString();		-- �����table,�����ToRichString()
				else
					value = tostring(self[v]);			-- ���������������,��tostring
				end
				if value then str = str.." "..k.."="..[["]]..value..[["]] end
			end	-- ��������
		end
	end
	str = str..">";
	if child_list then
		for k, v in pairs(child_list) do
			if self[v] then str = str..self[v]:ToRichString() end			-- �����ӱ�ǩ
		end
	end
	str = str.."</"..tagname..">";
	return str;
end
--=========================  EvUiLuaClass_Base  =========================
EvUiLuaClass_Base = {};
EvUiLuaClassAssistant_SetSuperClass(EvUiLuaClass_Base);

--=========================  EvUiLuaClass_Rect  =========================
EvUiLuaClass_Rect =
{
	x = 0,				-- number
	y = 0,				-- number
	width = 0,			-- number
	height = 0,			-- number
};
EvUiLuaClassAssistant_SetSuperClass(EvUiLuaClass_Rect, EvUiLuaClass_Base);

function EvUiLuaClass_Rect:new(_x, _y, _width, _height)
	local newObject = {};
	EvUiLuaClassAssistant_SetSuperClass(newObject, EvUiLuaClass_Rect);
	if _x ~= nil then newObject.x = _x end
	if _y ~= nil then newObject.y = _y end
	if _width ~= nil then newObject.width = _width end
	if _height ~= nil then newObject.height = _height end
	return newObject;
end
function EvUiLuaClass_Rect:ToRichString()
	return tostring(self.x)..","..tostring(self.y)..","..tostring(self.width)..","..tostring(self.height);
end
function EvUiLuaClass_Rect:GetX()
	return self.x;
end
function EvUiLuaClass_Rect:GetY()
	return self.y;
end
function EvUiLuaClass_Rect:GetRight()
	return self.x + self.width;
end
function EvUiLuaClass_Rect:GetBottom()
	return self.y + self.height;
end
function EvUiLuaClass_Rect:GetWidth()
	return self.width;
end
function EvUiLuaClass_Rect:GetHeight()
	return self.height;
end
function EvUiLuaClass_Rect:Inflate(_x, _y, _r, _b)
	self.x = self.x - _x;
	self.width = self.width + _x;
	self.y = self.y - _y;
	self.height = self.height + _y;
	self.width = self.width + _r;
	self.height = self.height + _b;
end
function EvUiLuaClass_Rect:IsIntersect(rect)
    if (rect:GetRight() < self.x) then
        return false;
	end
    if (rect.x > self:GetRight()) then
        return false;
	end
    if (rect:GetBottom() < self.y) then
        return false;
	end
    if (rect.y > self:GetBottom()) then
        return false;
	end
	return true;
end
function EvUiLuaClass_Rect:ContainPos(x, y)
	if x < self.x then return false end
	if x > self:GetRight() then return false end
	if y < self.y then return false end
	if y > self:GetBottom() then return false end
	return true;
end
function EvUiLuaClass_Rect:Clone()
	return EvUiLuaClass_Rect:new(self.x, self.y, self.width, self.height);
end
--=========================  EvUiLuaClass_ImageSource  =========================
EvUiLuaClass_ImageSource = 
{
	File = "EvUiLuaClassImage_Unknown",		-- string					-- �ļ���
	Rect = nil,								-- table (EvUiLuaClass_Rect)		-- ��Դ������
	Transparency = 100,						-- �ɼ���					-- 0Ϊ��ȫ͸��,100Ϊ��ȫ�ɼ�
	RichAttributeMap =
	{
		["File"] = "File",
		["Source"] = "Rect",
		["Transparency"] = "Transparency",
	},
};
EvUiLuaClassAssistant_SetSuperClass(EvUiLuaClass_ImageSource, EvUiLuaClass_Base);

function EvUiLuaClass_ImageSource:new(_file, _rect, _transparency)
	local newObject = {};
	EvUiLuaClassAssistant_SetSuperClass(newObject, EvUiLuaClass_ImageSource);
	if _file ~= nil then newObject.File = _file end
	if _rect ~= nil then newObject.Rect = _rect end
	if _transparency ~= nil then newObject.Transparency = _transparency end
	return newObject;
end
function EvUiLuaClass_ImageSource:ToRichString()
	return EvUiLuaRichTextAssistant_ToRichTextString(self, "Image", self.RichAttributeMap, nil);
end
--=========================  EvUiLuaClass_RichTextItem  =========================
EvUiLuaClass_RichTextItem =
{
	Type = nil,					-- string						-- ����  "TEXT"(�ı�)  "IMAGE"(ͼƬ)
	Param1 = nil,				-- any							-- ��ʱ����
	Param2 = nil,				-- any							-- ��ʱ����
	StrParam = nil,				-- string						-- ��ʱ����(string)
	Text = nil,					-- string						-- �ı�����
	Font = nil,					-- string						-- ����
	FontSize = nil,				-- number						-- �����С
	Color = nil,				-- string						-- �ı���ɫ ffffffff(ARGB)
	Hlink = nil,				-- string						-- ���� token:linkstring(token����Ϊ"Widget" "String" "File")
	ShadowColor = nil,			-- string						-- ��Ӱ��ɫ ffffffff(ARGB)
	UnderLine = nil,			-- bool						-- �Ƿ����»���
	CenterLine = nil,			-- bool						-- �Ƿ����л���
	ImageSource = nil,			-- table(EvUiLuaClass_ImageSource)		-- ͼƬ��Դ
	UnDetachable = nil,			-- bool						-- �Ƿ�ɷָ�
	RichAttributeMap = 
	{
		["type"] = "Type",
		["param1"] = "Param1",
		["param2"] = "Param2",
		["strParam"] = "StrParam",
		["text"] = "Text",
		["font"] = "Font",
		["fontsize"] = "FontSize",
		["color"] = "Color",
		["hlink"] = "Hlink",
		["shadowColor"] = "ShadowColor",
		["underLine"] = "UnderLine",
		["centerLine"] = "CenterLine",
		["undetachable"] = "UnDetachable",
	},
	RichChildTagMap =
	{
		["Image"] = "ImageSource",
	},
};
EvUiLuaClassAssistant_SetSuperClass(EvUiLuaClass_RichTextItem, EvUiLuaClass_Base);

function EvUiLuaClass_RichTextItem:new()
	local newObject = {};
	EvUiLuaClassAssistant_SetSuperClass(newObject, EvUiLuaClass_RichTextItem);
	return newObject;
end
function EvUiLuaClass_RichTextItem:ToRichString()
	return EvUiLuaRichTextAssistant_ToRichTextString(self, "Item", self.RichAttributeMap, self.RichChildTagMap);
end
--=========================  EvUiLuaClass_RichTextLine  =========================
EvUiLuaClass_RichTextLine =
{
	--ItemList = {}, -- ��new������
};
EvUiLuaClassAssistant_SetSuperClass(EvUiLuaClass_RichTextLine, EvUiLuaClass_Base);
function EvUiLuaClass_RichTextLine:new()
	local newObject = {};
	EvUiLuaClassAssistant_SetSuperClass(newObject, EvUiLuaClass_RichTextLine);
	newObject.ItemList = {};
	return newObject;
end
function EvUiLuaClass_RichTextLine:InsertItem(_item)  -- _item Ϊ table(EvUiLuaClass_RichTextItem)
	table.insert(self.ItemList, _item);
end
function EvUiLuaClass_RichTextLine:Reset()  -- _item Ϊ table(EvUiLuaClass_RichTextItem)
	self.ItemList = {};
end
function EvUiLuaClass_RichTextLine:ToRichString()  -- _line Ϊ table(EvUiLuaClass_RichTextLine)
	local str = [[<Line><Items>]];
	for _, item in ipairs(self.ItemList) do
		str = str..tostring(item:ToRichString());
	end
	str = str..[[</Items></Line>]];
	return str;
end
--=========================  EvUiLuaClass_RichText  =========================
EvUiLuaClass_RichText =
{
	--LineList = {},  -- ��new������
};
EvUiLuaClassAssistant_SetSuperClass(EvUiLuaClass_RichText, EvUiLuaClass_Base);
function EvUiLuaClass_RichText:new()
	local newObject = {};
	EvUiLuaClassAssistant_SetSuperClass(newObject, EvUiLuaClass_RichText);
	newObject.LineList = {};
	return newObject;
end
function EvUiLuaClass_RichText:InsertLine(_line)  -- _line Ϊ table(EvUiLuaClass_RichTextLine)
	table.insert(self.LineList, _line);
end
function EvUiLuaClass_RichText:Reset()  -- _line Ϊ table(EvUiLuaClass_RichTextLine)
	self.LineList = {};
end
function EvUiLuaClass_RichText:ToRichString()  -- _line Ϊ table(EvUiLuaClass_RichTextLine)
	local Result = [[<?xml version="1.0" encoding="UTF-8"?>]];
	Result = Result..[[<UiRichText>]];
	for _, line in ipairs(self.LineList) do
		Result = Result..line:ToRichString();
	end
	Result = Result..[[</UiRichText>]];
	return Result;
end

--=========================  EvUiLuaClass_ESpy  =========================
EvUiLuaClass_ESpy = 
{
};
function EvUiLuaClass_ESpy:new(name)
	local newObject = {};
	EvUiLuaClassAssistant_SetSuperClass(newObject, EvUiLuaClass_ESpy);
	newObject.mName = name;
	newObject.mTime = 0;
	return newObject;
end

function EvUiLuaClass_ESpy:Start()
	self.mTime = os.clock();
end

function EvUiLuaClass_ESpy:End()
	self.mTime = os.clock() - self.mTime;
end

function EvUiLuaClass_ESpy:Log()
	local message = string.format("EvUiLuaClass_ESpy:UseTime[%s] = %f", self.mName, self.mTime);
	uiInfo(message);
end

EV_UI_DEFINE_IMAGE_SOURCE_DEFINE =
{
	["Money_Gold"]		= EvUiLuaClass_ImageSource:new("ic_gold");
	["Money_Ag"]		= EvUiLuaClass_ImageSource:new("ic_ag");
	["Money_Cu"]		= EvUiLuaClass_ImageSource:new("ic_cu");
}


-- ��ݼ��Ĺ������
EV_UI_SHORTCUT_OWNER_KEY = "ev_ui_shortcut_owner"
EV_UI_SHORTCUT_OWNER_NONE = 0;
EV_UI_SHORTCUT_OWNER_BANK = 1;
EV_UI_SHORTCUT_OWNER_ITEM = 2;
EV_UI_SHORTCUT_OWNER_EQUIP = 3; -- ��ҵ�װ����
EV_UI_SHORTCUT_OWNER_MAIL = 4;
EV_UI_SHORTCUT_OWNER_NPC_SHOP_BUY_SELF = 5; -- NPC�̵깺����� (�ϰ벿��)
EV_UI_SHORTCUT_OWNER_NPC_SHOP_BUY_SHOP = 6; -- NPC�̵깺����� (�°벿��)
EV_UI_SHORTCUT_OWNER_NPC_SHOP_SALE_SELF = 7; -- NPC�̵귷������ (�ϰ벿��)
EV_UI_SHORTCUT_OWNER_NPC_SHOP_SALE_SHOP = 8; -- NPC�̵귷������ (�°벿��)
EV_UI_SHORTCUT_OWNER_GUILD_BANK = 9;        
EV_UI_SHORTCUT_OWNER_SKILL = 10;
EV_UI_SHORTCUT_OWNER_SHORTCUT = 11;
EV_UI_SHORTCUT_OWNER_MISC = 12;
EV_UI_SHORTCUT_OWNER_ATTRIBUTE = 13;
EV_UI_SHORTCUT_OWNER_AUCTION = 14;
EV_UI_SHORTCUT_OWNER_AUTO_BAR = 15; -- �Զ�ʹ�õ��ߵĽ���
EV_UI_SHORTCUT_OWNER_SIGN = 16;
EV_UI_SHORTCUT_OWNER_UNSIGN = 17;

-- ��ݼ������ͱ��
EV_UI_SHORTCUT_TYPE_KEY = "ev_ui_shortcut_type"

EV_SHORTCUT_OBJECT_NONE		= 0	--�ձ��
EV_SHORTCUT_OBJECT_SKILL	= 1	--���ܿ�ݱ��
EV_SHORTCUT_OBJECT_ITEM		= 2	--���߿�ݱ��
EV_SHORTCUT_OBJECT_MACRO	= 3	--���ݱ��
EV_SHORTCUT_OBJECT_MISC		= 4	--�����ݱ��


-- ��ݼ���Ӧ�ĵ��߻���ObjectId
EV_UI_SHORTCUT_OBJECTID_KEY = "ev_ui_shortcut_objectid"
EV_UI_SHORTCUT_OBJECTID_MISC_SIT				= 1;		-- ����
EV_UI_SHORTCUT_OBJECTID_MISC_PRACTICE			= 2;		-- ��������
EV_UI_SHORTCUT_OBJECTID_MISC_NORMALATTACK		= 3;		-- ��ͨ����
EV_UI_SHORTCUT_OBJECTID_MISC_ITEMFUSE			= 4;		-- �����ۺ�
EV_UI_SHORTCUT_OBJECTID_MISC_AUTOUSE			= 5;		-- ����Ʒ����
EV_UI_SHORTCUT_OBJECTID_MISC_CONCENTRATE		= 6;		-- ����

EV_UI_SHORTCUT_CLASSID_KEY = "ev_ui_shortcut_classid"

EV_UI_CURRENT_PAGE = "ev_ui_current_page";
EV_UI_ITEM_COORD3_KEY = "ev_ui_item_coord3_key"; -- ���ߵĶ�ά���� <line,column>

EV_UI_EQUIP_PART_KEY = "ev_ui_equip_part_key";	-- װ����λ

EV_UI_ITEM_DIVIDE_ID_KEY = "ev_ui_item_divide_id_key";	-- ��ֵĵ���id
EV_UI_ITEM_DIVIDE_COUNT_KEY = "ev_ui_item_divide_count_key";	-- ��ֵ�����

EV_UI_ITEM_IS_FREEZED_KEY = "ev_ui_item_is_freezed_key";	-- �Ƿ񶳽�

EV_UI_DELTA = "ev_ui_delta";	-- �ӳ�

SystemPopupMenuCallBackList = {};
SystemDefaultMessageBoxCallBack = {};

SAPI = {};

function SAPI.FindLanString(str)
	for s in string.gfind(str, "\$L:(.*)\$$") do
		return uiLanString(s);
	end
	return str;
end

function SAPI.GetLocalPath (object)
	local fullName = "";
	local objType = type(object);
	if objType == "userdata" then
		fullName = object:getName();
	elseif objType == "string" then
		fullName = object;
	else
		uiError("call GetLocalPath in GlobalAPI error!!!");
		return nil;
	end
	--return fullName.."__"..string.sub(fullName, 1, string.find(fullName, "(.)\.[^\.]+$"));
	return string.gsub(fullName, "\.[^\.]+$", "");
end

function SAPI.GetParent (object)
	if (type(object) ~= "userdata") then
		return nil;
	end
	return object:getParent();
end

function SAPI.GetChild (object, name)
	if (type(object) ~= "userdata") or (type(name) ~= "string") then
		return nil;
	end
	return uiGetChild(object, name);
end

function SAPI.GetSibling (object, name)
	if (type(object) ~= "userdata") or (type(name) ~= "string") then
		return nil;
	end
	local parent = object:getParent();
	if parent == nil then
		return nil;
	end
	return uiGetChild(parent, name);
end

function SAPI.SplitString(str, dot)
	local list = {};
	if dot == nil or type(dot) ~= "string" or dot == "" then return list end
	if str == nil or type(str) ~= "string" or str == "" then return list end
	str = str..dot;
	for s in string.gfind(str, "(.-)["..dot.."]") do
		table.insert(list, s);
	end
	return list;
end

function SAPI.GetImage(Filename, RenderOffsetLeft, RenderOffsetTop, RenderOffsetRight, RenderOffsetLeftBottom)
	if not Filename then return end
	if not RenderOffsetLeft then
		RenderOffsetLeft = 0;
	end
	if not RenderOffsetTop then
		RenderOffsetTop = 0;
	end
	if not RenderOffsetRight then
		RenderOffsetRight = 0;
	end
	if not RenderOffsetLeftBottom then
		RenderOffsetLeftBottom = 0;
	end
	return uiGetImage(Filename, RenderOffsetLeft, RenderOffsetTop, RenderOffsetRight, RenderOffsetLeftBottom);
end

function SAPI.AddDefaultPopupMenuCallBack(_func, _arg)
	if _func == nil or type(_func) ~= "function" then
		uiError("SAPI.SetDefaultPopupMenuCallBack : argument #1 must be the type of [function].");
		return;
	end
	local FuncTable = {F=_func, Arg=_arg};
	for _, FTable in ipairs(SystemPopupMenuCallBackList) do
		if SAPI.Equal(FTable.F, _func) then
			FTable.Arg = _arg;
			return;
		end
	end
	table.insert(SystemPopupMenuCallBackList, FuncTable);
end

function SAPI.RemoveDefaultPopupMenuCallBack()
	SystemPopupMenuCallBackList = {};
end

function SAPI.AddDefaultMessageBoxCallBack(_frame, _funcOk, _funcCancel, _arg, _funcUpdate)
	if not _frame or type(_frame) ~= "userdata" then return false end
	SAPI.AddWidgetCallBack(_frame, "Ok", _funcOk, _arg);
	SAPI.AddWidgetCallBack(_frame, "Cancel", _funcCancel, _arg);
	SAPI.AddWidgetCallBack(_frame, "Update", _funcUpdate, _arg);
	return true;
end

function SAPI.AddDefaultInputBoxCallBack(_frame, _funcOk, _funcCancel, _arg, _funcUpdate)
	if not _frame or type(_frame) ~= "userdata" then return false end
	SAPI.AddWidgetCallBack(_frame, "Ok", _funcOk, _arg);
	SAPI.AddWidgetCallBack(_frame, "Cancel", _funcCancel, _arg);
	SAPI.AddWidgetCallBack(_frame, "Update", _funcUpdate, _arg);
	return true;
end

function SAPI.AddWidgetCallBack(_frame, _event, _function, _arg)
	if not _frame or not _event or not _function or type(_function) ~= "function" then return end
	local key = tostring(_frame);
	if not SystemDefaultMessageBoxCallBack[key] then SystemDefaultMessageBoxCallBack[key] = {} end
	if not SystemDefaultMessageBoxCallBack[key][_event] then SystemDefaultMessageBoxCallBack[key][_event] = {} end
	SystemDefaultMessageBoxCallBack[key][_event] = {CallBack=_function, Argument=_arg};
end

function SAPI.CallWidgetCallBackFunction(_box, _frame, _event, _arg)
	if not _frame or not _event then return end
	local key = tostring(_frame);
	if not SystemDefaultMessageBoxCallBack or not SystemDefaultMessageBoxCallBack[key] or not SystemDefaultMessageBoxCallBack[key][_event] then return end
	local f = SystemDefaultMessageBoxCallBack[key][_event].CallBack;
	local arg = SystemDefaultMessageBoxCallBack[key][_event].Argument;
	f(_event, arg, _arg, _box, _frame);
end

function SAPI.RemoveWidgetCallBack(_frame, _event)
	if _frame == nil then return end
	local key = tostring(_frame);
	if SystemDefaultMessageBoxCallBack == nil then return end
	if _event == nil then
		SystemDefaultMessageBoxCallBack[key] = nil;
	else
		SystemDefaultMessageBoxCallBack[key][_event] = nil;
	end
end

function SAPI.CreateNewDataByFormat(_format)
	local newData = {};
	if _format == nil then
		return nil;
	end
	if type(_format) ~= "table" then
		return nil;
	end
	if _format["auto"] ~= nil then
		local tmp = SAPI.CreateNewDataByFormat(_format["auto"]);
		if tmp ~= nil then
			newData = tmp;
		end
	end
	if _format["tables"] ~= nil then
		for _, tableName in ipairs(_format["tables"]) do
			local tmp = SAPI.CreateNewDataByFormat(_format[tableName]);
			if tmp == nil then
				newData[tableName] = tmp;
			else
				newData[tableName] = {};
			end
		end
	end
	return newData;
end

function SAPI.Equal(p1, p2)
	if p1 == nil or p2 == nil then return false end
	return ((type(p1) == type(p2)) and (tostring(p1) == tostring(p2)));
end

function SAPI.ExistInTable(_table, _element)
	if _table == nil or type(_table) ~= "table" or _element == nil then
		return false;
	end
	for i, o in ipairs(_table) do
		if (SAPI.Equal(_element, o) == true) then
			return true, i;
		end
	end
	return false;
end

function SAPI.GetIndexInTable(_table, _element)
	if _table == nil or type(_table) ~= "table" or _element == nil then
		return 0;
	end
	for i, o in ipairs(_table) do
		if (SAPI.Equal(_element, o) == true) then
			return i;
		end
	end
	return 0;
end

function SAPI.SortToArrty(_table)
	local tIndex = {};
	local result = {};
	if _table == nil then return result end
	for n, _ in pairs(_table) do
		if type(n) ~= "number" then
			uiError("SAPI.SortToArrty : ��������������");
			return result;
		end
		table.insert(tIndex, n);
	end
	table.sort(tIndex);
	for _, v in ipairs(tIndex) do
		table.insert(result, _table[v]);
	end
	return result;
end

function SAPI.GetPartyName(party)
	if party < 0 or party > table.getn(PartyInfoList) or PartyInfoList[party + 1]["Name"] == nil then
		return "";
	end
	return SAPI.FindLanString(PartyInfoList[party + 1]["Name"]);
end

function SAPI.Trim(s)
	if s and type(s) == "string" then
		return (string.gsub(s, "^%s*(.-)%s*$", "%1"));
	end
	return "";
end

function SAPI.SetHeadIcon3D(ModelView, ObjectId)
	if not ModelView or not ObjectId then return end
	ObjectId = tonumber(ObjectId);
	local self = ModelView;
	
	local ModelInfo = uiGetGameModelInfo(ObjectId)
	local Model = ModelInfo.Model;
	if not Model then
		self:Hide();
		return;
	end
	local ModelId = Model.Id;
	local ModelFile = Model.File;
	local Skins = ModelInfo.Skins;
	local Links = ModelInfo.Links;
	local ReplaceSkin = ModelInfo.ReplaceSkin;
	local ReplaceMaterial = ModelInfo.ReplaceMaterial;
	local SkinColor = ModelInfo.SkinColor;
	
	local CurModelId = self:Get("CurModelId");
	--if not CurModelId or CurModelId ~= ModelId then
		self:SetModel(ModelFile)
		self:Set("CurModelId", ModelId)
	--end
	self:SetModelScale(1, 1, 1);
	if Skins then
		for i, skin in ipairs(Skins) do
			local name = skin.Name;
			local file = skin.File;
			local res = self:LoadSkin(name, file);
		end
	end
	if Links then
		for i, link in ipairs(Links) do
			local partName = link.PartName;
			local subIndex = link.SubIndex;
			local linkSlot = link.LinkSlot;
			local file = link.File;
			local res = self:LinkModel(file, partName..subIndex, linkSlot);
		end
	end
	if ReplaceSkin and ReplaceSkin ~= "" then
		self:ReplaceSkin(ReplaceSkin);
	end
	if ReplaceMaterial and ReplaceMaterial ~= "" then
		self:ReplaceMaterial(ReplaceMaterial);
	end
	if SkinColor then
		self:SetSkinColor(SkinColor.x, SkinColor.y, SkinColor.z);
	end
	-- ���������
	local CameraEye = ModelInfo.Camera.Eye;
	local CameraLookAt = ModelInfo.Camera.LookAt;
	self:SetCameraEye(CameraEye.x, CameraEye.y, CameraEye.z, false);
	self:SetCameraLookAt(CameraLookAt.x, CameraLookAt.y, CameraLookAt.z);
	self:Show();
	return true;
end

function SAPI.DoDragAction(wtFrom, wtTo)
	if wtFrom == nil then return false end
	if wtTo == nil then return false end
end

function SAPI.GetMoneyShowStyle(money)
	if money == nil then money = 0 end
	local gold, silver, copper = uiGetMoneyShowStyle(money);
	return gold, silver, copper;
end

function SAPI.GetMoneyFromShowStyle(gold, silver, copper)
	if type(gold) ~= "number" then gold = tonumber(gold) end
	if gold == nil then gold = 0 end
	if type(silver) ~= "number" then silver = tonumber(silver) end
	if silver == nil then silver = 0 end
	if type(copper) ~= "number" then copper = tonumber(copper) end
	if copper == nil then copper = 0 end
	local money = gold * 10000 + silver * 100 + copper;
	return money;
end

--Ԫ��ƺ�
function SAPI.GetGodTitle(nGodLevel)
	local title = "";
	if nGodLevel >=1 and nGodLevel <= 3 then
		title = "msg_god1_1";
 	elseif nGodLevel >= 4 and nGodLevel <= 6 then
		title = "msg_god1_2";
	elseif nGodLevel >= 7 and nGodLevel <= 10 then
		title = "msg_god1_3";
	elseif nGodLevel >= 11 and nGodLevel <= 13 then
		title = "msg_god2_1";
	elseif nGodLevel >= 14 and nGodLevel <= 16 then
		title = "msg_god2_2";
	elseif nGodLevel >= 17 and nGodLevel <= 20 then
		title = "msg_god2_3";
	elseif nGodLevel >= 21 and nGodLevel <= 23 then
		title = "msg_god3_1";
	elseif nGodLevel >= 24 and nGodLevel <= 26 then
		title = "msg_god3_2";
	elseif nGodLevel >= 27 and nGodLevel <= 30 then
		title = "msg_god3_3";
	elseif nGodLevel >= 31 and nGodLevel <= 33 then
		title = "msg_god4_1";
	elseif nGodLevel >= 34 and nGodLevel <= 36 then
		title = "msg_god4_2";
	elseif nGodLevel >= 37 and nGodLevel <= 40 then
		title = "msg_god4_3";
	elseif nGodLevel >= 41 and nGodLevel <= 43 then
		title = "msg_god5_1";
	elseif nGodLevel >= 44 and nGodLevel <= 46 then
		title = "msg_god5_2";
	elseif nGodLevel >= 47 and nGodLevel <= 50 then
		title = "msg_god5_3";
	elseif nGodLevel >= 51 and nGodLevel <= 53 then
		title = "msg_god6_1";
	elseif nGodLevel >= 54 and nGodLevel <= 56 then
		title = "msg_god6_2";
	elseif nGodLevel >= 57 and nGodLevel <= 60 then
		title = "msg_god6_3";
	elseif nGodLevel >= 61 and nGodLevel <= 63 then
		title = "msg_god7_1";
	elseif nGodLevel >= 64 and nGodLevel <= 66 then
		title = "msg_god7_2";
	elseif nGodLevel >= 67 and nGodLevel <= 70 then
		title = "msg_god7_3";
	elseif nGodLevel >= 71 and nGodLevel <= 73 then
		title = "msg_god8_1";
	elseif nGodLevel >= 74 and nGodLevel <= 76 then
		title = "msg_god8_2";
	elseif nGodLevel >= 77 and nGodLevel <= 80 then
		title = "msg_god8_3";
	elseif nGodLevel >= 81 and nGodLevel <= 83 then
		title = "msg_god9_1";
	elseif nGodLevel >= 84 and nGodLevel <= 86 then
		title = "msg_god9_2";
	elseif nGodLevel >= 87 and nGodLevel <= 90 then
		title = "msg_god9_3";
	else
	    title = "msg_god1";
	end
	return LAN(title);
end

function SAPI.SetGameCursor (Cursor)
	local cursor = uiGetGameCursor();
	if not Cursor or cursor == Cursor or cursor == EV_GAME_CURSOR_NONE then return end
	uiGetGameCursor(Cursor);
end





