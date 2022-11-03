--*********************
-- lay_new_character2
--*********************

local CharacterSelectionParty =
{
	["CharacterSelection0"] = 0;
	["CharacterSelection1"] = 1;
	["CharacterSelection2"] = 2;
	["CharacterSelection3"] = 3;
	["CharacterSelection4"] = 4;
}

local CharacterSelectionList =
{
	["CurSelect"] = nil;
};

local CharacterAttributeSelectionList =
{
	["CurSelect"] = {};
};

-- 0 ����
-- 1 ����
-- 2 ���
-- 3 �ٻ�
-- 4 ����

function CharacterSelection_Enter()
	uiCharSelectCharacter(-1, -1);
	CharacterSelectionList["CurSelect"] = nil;
	for _, obj in ipairs(CharacterSelectionList) do
		obj:Enable();
		obj:SetChecked(false);
		local ckbMale = uiGetChild(obj, "ckbMale");
		local ckbFemale = uiGetChild(obj, "ckbFemale");
		ckbMale:SetChecked(false);
		ckbFemale:SetChecked(false);
		local party = CharacterSelectionParty[obj:getShortName()];--table.getn(CharacterSelectionList) - 1;
		local bMaleAllowed = uiIsCharacterAllowed(party, 0);
		local bFemaleAllowed = uiIsCharacterAllowed(party, 1);
		if bMaleAllowed == true and bFemaleAllowed == true then
			ckbMale:SetSize(47,15);
			ckbFemale:SetSize(47,15);
			ckbFemale:ActiveAnchor();
		elseif bMaleAllowed == true then
			ckbMale:SetSize(95,15);
			ckbFemale:Hide();
		elseif bFemaleAllowed == true then
			ckbMale:Hide();
			ckbFemale:SetSize(95,15);
			ckbFemale:ActiveAnchor();
		else
			obj:Disable();
			ckbMale:Hide();
			ckbFemale:Hide();
		end
	end
	local edbCharName = uiGetglobal("layCreateChar2.lbRollControler.lbRoleAttribute.edbCharName");
	if edbCharName then
		edbCharName:SetText("");
	end
end

function CharacterSelection_OnLoad(self)
	table.insert(CharacterSelectionList, self); -- ע��ؼ�
end

function CharacterSelection_OnLClick(self)
	local ckbMale = uiGetChild(self, "ckbMale");
	local ckbFemale = uiGetChild(self, "ckbFemale");
	if ckbMale:getVisible() == true then
		CharacterSelection_Sex_OnLClick(ckbMale, 0);
	elseif ckbFemale:getVisible() == true then
		CharacterSelection_Sex_OnLClick(ckbFemale, 1);
	else
		self:SetChecked(false);
	end
end

function CharacterAttributeSelection_OnLoad(self)
	table.insert(CharacterAttributeSelectionList, self); -- ע��ؼ�
end
-- ͳһ����ѡ��
function CharacterSelection_Sex_OnLClick(self, sex)
	local object = self:getParent();
	local party = CharacterSelectionParty[object:getShortName()];--SAPI.GetIndexInTable(CharacterSelectionList, object);
	if party >= 0 then
		local curParty, curSex = uiCharGetCurrentCharacterInfo();
		if (curParty == party and curSex == sex) then
			uiCharSelectCharacter(-1, -1);
		else
			uiCharSelectCharacter(party, sex);
		end
	end
end
-- ��Ӧͨ������ѡ������
function CharacterSelection_SelectChanged(party, sex)
	CharacterSelectionList["CurSelect"] = nil;
	for i, obj in ipairs(CharacterSelectionList) do
		local ckbParty = uiGetChild(obj, "ckbParty");
		local ckbMale = uiGetChild(obj, "ckbMale");
		local ckbFemale = uiGetChild(obj, "ckbFemale");
		if (CharacterSelectionParty[obj:getShortName()] == party) then
			CharacterSelectionList["CurSelect"] = obj;
			ckbParty:SetChecked(true);
			obj:SetChecked(true);
			if (sex == 0) then -- �е�
				ckbMale:SetChecked(true);
				ckbFemale:SetChecked(false);
			else -- ȫ��Ů��
				ckbMale:SetChecked(false);
				ckbFemale:SetChecked(true);
			end
		else
			obj:SetChecked(false);
			ckbParty:SetChecked(false);
			ckbFemale:SetChecked(false);
			ckbMale:SetChecked(false);
		end
	end
	CharacterSelection_ResetAttributes();
	local edbCharName = uiGetglobal("layCreateChar2.lbRollControler.lbRoleAttribute.edbCharName");
	local lbIndex = uiGetglobal("layCreateChar2.lbRollControler.lbIndex");
	local lbRoleAttribute = uiGetglobal("layCreateChar2.lbRollControler.lbRoleAttribute");
	if CharacterSelectionList["CurSelect"] then
		edbCharName:Enable();
		lbIndex:ModifyFlag("MouseEvent", true);
		lbRoleAttribute:ModifyFlag("MouseEvent", true);
		lbIndex:ModifyFlag("MouseMove", true);
		lbRoleAttribute:ModifyFlag("MouseMove", true);
		for i, obj in ipairs(CharacterAttributeSelectionList) do
			obj:Enable();
		end
	else
		lbIndex:ModifyFlag("MouseEvent", false);
		lbRoleAttribute:ModifyFlag("MouseEvent", false);
		lbIndex:ModifyFlag("MouseMove", false);
		lbRoleAttribute:ModifyFlag("MouseMove", false);
		edbCharName:Disable();
		for i, obj in ipairs(CharacterAttributeSelectionList) do
			obj:Disable();
		end
	end
end
-- ѡ�������Խ�ɫ
function CharacterSelection_ckbMale_OnLClick(self)
	CharacterSelection_Sex_OnLClick(self, 0);
end
-- ѡ����Ů�Խ�ɫ
function CharacterSelection_ckbFemale_OnLClick(self)
	CharacterSelection_Sex_OnLClick(self, 1);
end
function CharacterSelection_GetAttributeString(index)
	if index == 1 then
		return "Hair";
	elseif index == 2 then
		return "Head";
	end
	return nil;
end
-- ˢ��UIͬ����ʾ
function CharacterSelectionUpdate()
	local lbDesc = nil;
	local strAttr = nil;
	for i, obj in ipairs(CharacterAttributeSelectionList) do
		strAttr = CharacterSelection_GetAttributeString(i);
		lbDesc = uiGetChild(obj, "lbDesc");
		if lbDesc and strAttr then
			local _, desc = uiCharGetCurrentCharacterAttributeInfo(strAttr);
			if desc == nil then
				desc = "";
			end
			lbDesc:SetText(desc);
		end
	end
	local _, sPartyDesc = uiCharGetCurrentCharacterAttributeInfo("Party");
	local edbPartyDesc = uiGetglobal("layCreateChar2.lbRollControler.lbIndex.edbIndex");
	if edbPartyDesc and sPartyDesc then
		edbPartyDesc:SetText(sPartyDesc);
	end
end
-- �ı����� ( ��ť )
function CharacterAttributeSelection_btLeft_OnLClick(self)
	local selName = nil;
	local parent = SAPI.GetParent(self);
	local lbDesc = SAPI.GetSibling(self, "lbDesc");
	local strAttr = nil;
	local index = SAPI.GetIndexInTable(CharacterAttributeSelectionList, parent);
	strAttr = CharacterSelection_GetAttributeString(index);
	if strAttr then
		_, selName = uiCharPreCharacterAttribute(strAttr);
	end
	if selName and lbDesc then
		lbDesc:SetText(selName);
	end
end
-- �ı����� ( �Ұ�ť )
function CharacterAttributeSelection_btRight_OnLClick(self)
	local selName = nil;
	local parent = SAPI.GetParent(self);
	local lbDesc = SAPI.GetSibling(self, "lbDesc");
	local strAttr = nil;
	local index = SAPI.GetIndexInTable(CharacterAttributeSelectionList, parent);
	strAttr = CharacterSelection_GetAttributeString(index);
	if strAttr then
		_, selName = uiCharNextCharacterAttribute(strAttr);
	else
		uiError("strAttr == " .. tostring(strAttr));
	end
	if selName and lbDesc then
		lbDesc:SetText(selName);
	else
		uiError("selName == " .. tostring(selName));
	end
end
-- ������ҽ�ɫ
function layCreateChar2_btAccept_OnLClick(self)
	layCreateChar2_DoAccept();
end
-- �������н���
function CharacterSelection_Leave()
	uiCharSelectCharacter(-1, -1);
	uiGetglobal("layCreateChar2.lbRollControler"):SetTransparency(0);
end
-- ��Ӧ�������� ( �� [����] [�Ա�] ������������� )
function CharacterSelection_ResetAttributes()
	uiCharSelectCharacterAttribute("Hair", 0);
	uiCharSelectCharacterAttribute("Head", 0);
	--uiCharSelectCharacterAttribute("Shape", 0);
	--uiCharSelectCharacterAttribute("SkinColor", 0);
	CharacterSelectionUpdate();
end

function layCreateChar2_lbRollControler_OnUpdate(self)
	local curTrans = self:getTransparency(); -- ��ȡ��ǰ͸����
	if CharacterSelectionList["CurSelect"] then
		if curTrans >= 0.991 then return end
		self:SetTransparency(curTrans + 0.01);
	else
		if curTrans <= 0.009 then return end
		self:SetTransparency(curTrans - 0.01);
	end
end

function layCreateChar2_edbCharName_OnTextChanged(self)
	local curText = self:getText();
	if curText and string.len(curText) > 2 then
		uiGetglobal("layCreateChar2.btAccept"):Enable();
	else
		uiGetglobal("layCreateChar2.btAccept"):Disable();
	end
end

function layCreateChar2_edbCharName_OnKeyDown(self, key)
	if uiGetKeyName(key) == "ENTER" then
		layCreateChar2_DoAccept();
	end
end

function layCreateChar2_DoAccept()
	if CharacterSelectionList["CurSelect"] == nil then return; end
	if uiGetglobal("layCreateChar2.btAccept"):getEnable() == false then return; end
	local edbCharName = uiGetglobal("layCreateChar2.lbRollControler.lbRoleAttribute.edbCharName");
	if edbCharName == nil then return end
	local name = edbCharName:getText();
	if name == nil then return; end
	uiCharCreateCharacter(name);
end




