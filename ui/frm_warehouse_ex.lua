UI_Bank_Npc_Object_Id = 0

local UI_BANK_ALLOWED_MAX_GRID_COUNT = 30
local UI_ULTRABANK_ALLOWED_MAX_COUNT = 6

function layWorld_frmWarehouseEx_OnUpdate(self)
	if uiGuild_NpcDialogCheckDistance(UI_Bank_Npc_Object_Id) ~= true then self:Hide() return end
end

function layWorld_frmWarehouseEx_Bank_Recv_Date(self, arg)
	layWorld_frmWarehouseEx_Refresh()
	layWorld_frmWarebagEx_Refresh()
	UI_Bank_Npc_Object_Id = arg[1]
	if UI_Bank_Npc_Object_Id ~= 0 then
		self:MoveTo(80, 180)
		self:ShowAndFocus()
		local name = uiGetMyInfo("Role")
		local lbWarehouse = SAPI.GetChild(self, "lbWarehouse")
		lbWarehouse:SetText(string.format(uiLanString("MSG_XX_BANK"), name))
	end
end

function layWorld_frmWarehouseEx_Restructuring()
	local self = uiGetglobal("layWorld.frmWarehouseEx")
	
	local lbItems = SAPI.GetChild(self, "lbItems")

	for i = 1, UI_BANK_ALLOWED_MAX_GRID_COUNT, 1 do
		local btItem = SAPI.GetChild(lbItems, "btItem"..i)
		btItem:Hide()
	end

	for i=1, UI_ULTRABANK_ALLOWED_MAX_COUNT, 1 do
		local BtBag = SAPI.GetChild(self, "BtBag"..i)
		BtBag:Hide()
	end

	local info = uiBank_GetBankSystemInfo()
	local slot = info.BankSlot.Bank

	for i=1, info.BankSlot.UltraBank.Page, 1 do
		local BtBag = SAPI.GetChild(self, "BtBag"..i)
		BtBag:Show()
	end

	-- 初始化界面元素
	local width = slot.Right - slot.Left + 1
	local height = slot.Bottom - slot.Top + 1

	lbItems:MoveSize(slot.Left, slot.Top, width, height)

	for i=1, slot.Line, 1 do
		for j=1, slot.Col, 1 do
			local btItem = SAPI.GetChild(lbItems, "btItem"..((i - 1)*slot.Col + j))
			btItem:Show()
			local left = slot.OffsetLeft + (j-1)*slot.Width
			local top = slot.OffsetTop + (i-1)*slot.Height
			local width = slot.OffsetRight - slot.OffsetLeft + 1
			local height = slot.OffsetRight - slot.OffsetLeft + 1
			btItem:MoveSize(left, top, width, height)
		end
	end

end

function layWorld_frmWarehouseEx_Refresh()
	local self = uiGetglobal("layWorld.frmWarehouseEx")
	
	local lbItems = SAPI.GetChild(self, "lbItems")

	local line, col = uiBank_GetBankDefaultLineCol()
	for i=1, line, 1 do
		for j=1, col, 1 do
			local btItem = SAPI.GetChild(lbItems, "btItem"..((i - 1)*col + j))
			btItem:Delete(EV_UI_SHORTCUT_TYPE_KEY)
			btItem:Delete(EV_UI_SHORTCUT_OWNER_KEY)
			btItem:Delete(EV_UI_SHORTCUT_OBJECTID_KEY)
			btItem:Delete(EV_UI_SHORTCUT_CLASSID_KEY)
			local imgstr, itemCount, itemOid, itemCid = uiBank_GetBankItemInfoByLineCol(i, j)
			if imgstr ~= nil then
				local image_item = SAPI.GetImage(imgstr)
				if image_item ~= nil then
					btItem:SetBackgroundImage(image_item)
					btItem:ModifyFlag("DragOut", true)
					btItem:Set(EV_UI_SHORTCUT_TYPE_KEY, EV_SHORTCUT_OBJECT_ITEM)
					btItem:Set(EV_UI_SHORTCUT_OWNER_KEY, EV_UI_SHORTCUT_OWNER_BANK)
					btItem:Set(EV_UI_SHORTCUT_OBJECTID_KEY, itemOid)
					btItem:Set(EV_UI_SHORTCUT_CLASSID_KEY, itemCid)
					if itemCount == -1 or itemCount == nil then
						btItem:SetUltraTextNormal("")
					else
						btItem:SetUltraTextNormal(""..itemCount)
					end
				else
					btItem:SetBackgroundImage(0)
					btItem:ModifyFlag("DragOut", false)
					btItem:SetUltraTextNormal("")
				end
			else
				btItem:SetBackgroundImage(0)
				btItem:ModifyFlag("DragOut", false)
				btItem:SetUltraTextNormal("")
			end

			if btItem:IsHovered() then
				layWorld_frmWarehouseEx_btItem_OnHint(btItem)
			end

		end
	end

	layWorld_frmWarehouseEx_RefreshBankMoney()

	local bagCount = uiBank_GetUltraBagMaxCountLineCol()

	for i=1, bagCount, 1 do
		local BtBag = SAPI.GetChild(self, "BtBag"..i)
		if i > uiBank_GetUltraBagCount() then
			BtBag:SetNormalImage(0)
			BtBag:Disable()
		else
			local imgbag = SAPI.GetImage("ic_it068",2, 2, -2, -2)
			if imgbag ~= nil then
				BtBag:SetNormalImage(imgbag)
			end
			BtBag:Enable()
		end
	end

end

function layWorld_frmWarehouseEx_RefreshBankMoney()
	local self = uiGetglobal("layWorld.frmWarehouseEx")

	local goldnum = SAPI.GetChild(self, "goldnum")
	local silvernum = SAPI.GetChild(self, "silvernum")
	local coppernum = SAPI.GetChild(self, "coppernum")

	local __gold,__silver,__copper = uiBank_GetBankMoney()
	goldnum:SetText(""..__gold)
	silvernum:SetText(""..__silver)
	coppernum:SetText(""..__copper)
end

function layWorld_frmWarehouseEx_btItem_OnHint(self)
	local lbItems = uiGetglobal("layWorld.frmWarehouseEx.lbItems")

	local line, col = uiBank_GetBankDefaultLineCol()
	for i=1, line, 1 do
		for j=1, col, 1 do
			local btItem = SAPI.GetChild(lbItems, "btItem"..((i - 1)*col + j))
			if SAPI.Equal(self, btItem) then
				local _, _, _, _, richText = uiBank_GetBankItemInfoByLineCol(i, j)
				if richText ~= nil then
					self:SetHintRichText(richText)
				else
					self:SetHintRichText(0)
				end
				return
			end
			
		end
	end
end

function layWorld_frmWarehouseEx_btItem_OnRClick(self)

	if self:Get(EV_UI_SHORTCUT_TYPE_KEY) ~= EV_SHORTCUT_OBJECT_ITEM then
		return
	end

	if self:Get(EV_UI_SHORTCUT_OWNER_KEY) ~= EV_UI_SHORTCUT_OWNER_BANK then
		return
	end

	local itemOid = self:Get(EV_UI_SHORTCUT_OBJECTID_KEY)
	if itemOid == nil then
		return
	end

	if UI_Bank_Npc_Object_Id == 0 or UI_Bank_Npc_Object_Id == nil then
		return
	end

	uiBank_TakeOutBankItem(itemOid, UI_Bank_Npc_Object_Id)
end

function layWorld_frmWarehouseEx_btItem_OnDragIn(self, drag)

	if UI_Bank_Npc_Object_Id == 0 or UI_Bank_Npc_Object_Id == nil then
		return
	end

	local lbItems = uiGetglobal("layWorld.frmWarehouseEx.lbItems")
	local wDrag = uiGetglobal(drag)

	if wDrag:Get(EV_UI_SHORTCUT_TYPE_KEY) ~= EV_SHORTCUT_OBJECT_ITEM then
		return
	end

	local itemOid = wDrag:Get(EV_UI_SHORTCUT_OBJECTID_KEY)
	if itemOid == nil then
		return
	end

	local line, col = uiBank_GetBankDefaultLineCol()
	for i=1, line, 1 do
		for j=1, col, 1 do
			local btItem = SAPI.GetChild(lbItems, "btItem"..((i - 1)*col + j))
			if SAPI.Equal(self, btItem) then
				uiBank_ItemPutInDefaultBank(itemOid, i, j, UI_Bank_Npc_Object_Id)
				return
			end
		end

	end
end

function layWorld_frmWarehouseEx_BtBag_OnLClick(self)
	local frmWarehouseEx = uiGetglobal("layWorld.frmWarehouseEx")
	for i=1, uiBank_GetUltraBagCount(), 1 do
		local BtBag = SAPI.GetChild(frmWarehouseEx, "BtBag"..i)
		if SAPI.Equal(self, BtBag) then
			if BtBag:getChecked() then
				layWorld_frmWarebagEx_Show(i)
			else
				layWorld_frmWarebagEx_Hide()
			end
		else
			BtBag:SetChecked(false)
		end
	end
end

function layWorld_frmWarehouseEx_OnHide()
	layWorld_frmWarebagEx_Hide()
end

function layWorld_frmWarehouseEx_btnSaveMoney_OnLClick()
	local frmBankSetmoneyEx = uiGetglobal("layWorld.frmBankSetmoneyEx")
	frmBankSetmoneyEx:Set("save", true)
	frmBankSetmoneyEx:ShowAndFocus()
end

function layWorld_frmWarehouseEx_btnLoadMoney_OnLClick()
	local frmBankSetmoneyEx = uiGetglobal("layWorld.frmBankSetmoneyEx")
	frmBankSetmoneyEx:Set("save", false)
	frmBankSetmoneyEx:ShowAndFocus()
end