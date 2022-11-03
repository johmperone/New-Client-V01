local UI_Bank_Ware_Bag_Current_Open = 0

local UI_BANKBAG_ALLOWED_MAX_GRID_COUNT = 12

function layWorld_frmWarebagEx_Restructuring()
	local self = uiGetglobal("layWorld.frmWarebagEx")
	for i=1, UI_BANKBAG_ALLOWED_MAX_GRID_COUNT, 1 do 
		local BtWbag = SAPI.GetChild(self, "BtWbag"..i)
		BtWbag:Hide()
	end

	local info = uiBank_GetBankSystemInfo()
	local slot = info.BankSlot.UltraBank

	for i=1, slot.Line, 1 do
		for j=1, slot.Col, 1 do
			local BtWbag = SAPI.GetChild(self, "BtWbag"..((i - 1)*slot.Col + j))
			BtWbag:Show()
			local left = slot.Left + slot.OffsetLeft + (j-1)*slot.Width
			local top = slot.Top + slot.OffsetTop + (i-1)*slot.Height
			local width = slot.OffsetRight - slot.OffsetLeft + 1
			local height = slot.OffsetRight - slot.OffsetLeft + 1
			BtWbag:MoveSize(left, top, width, height)
		end
	end
end

function layWorld_frmWarebagEx_Refresh()
	local self = uiGetglobal("layWorld.frmWarebagEx")

	if UI_Bank_Ware_Bag_Current_Open > uiBank_GetUltraBagCount() then
		return
	end

	if UI_Bank_Ware_Bag_Current_Open < 1 then
		return
	end

	local bagEndTime = uiBank_GetUltraBagEndTime(UI_Bank_Ware_Bag_Current_Open)

	local lbTimeLimit = SAPI.GetChild(self, "lbTimeLimit")

	local bOutOfDate = false

	if bagEndTime == 0 then
		lbTimeLimit:SetText("")
	else
		if uiGetServerTime() >= bagEndTime then
			lbTimeLimit:SetTextColorEx(17,17,224,255)
			bOutOfDate = true
		else
			lbTimeLimit:SetTextColorEx(224,224,224,255)
		end
		local _year,_month,_day,_hour,_min = uiBank_TimeGetDate(bagEndTime)
		lbTimeLimit:SetText(string.format(uiLanString("msg_leasingtime"), _year,_month,_day,_hour,_min))
	end

	

	local _, line, col = uiBank_GetUltraBagMaxCountLineCol()

	for i=1, line, 1 do
		for j=1, col, 1 do
			local BtWbag = SAPI.GetChild(self, "BtWbag"..((i - 1)*col + j))
			BtWbag:Delete(EV_UI_SHORTCUT_TYPE_KEY)
			BtWbag:Delete(EV_UI_SHORTCUT_OWNER_KEY)
			BtWbag:Delete(EV_UI_SHORTCUT_OBJECTID_KEY)
			local imgstr, itemCount, itemOid = uiBank_GetBankUltraItemInfoByLineCol(UI_Bank_Ware_Bag_Current_Open, i, j)
			if imgstr ~= nil then
				local image_item = SAPI.GetImage(imgstr, 2, 2, -2, -2)
				if image_item ~= nil then
					BtWbag:SetNormalImage(image_item)
					if bOutOfDate then
						BtWbag:ModifyFlag("DragOut", false)
					else
						BtWbag:ModifyFlag("DragOut", true)
					end
					
					BtWbag:Set(EV_UI_SHORTCUT_TYPE_KEY, EV_SHORTCUT_OBJECT_ITEM)
					BtWbag:Set(EV_UI_SHORTCUT_OWNER_KEY, EV_UI_SHORTCUT_OWNER_BANK)
					BtWbag:Set(EV_UI_SHORTCUT_OBJECTID_KEY, itemOid)
					if itemCount == -1 or itemCount == nil then
						BtWbag:SetUltraTextNormal("")
					else
						BtWbag:SetUltraTextNormal(""..itemCount)
					end
				else
					BtWbag:SetNormalImage(0)
					BtWbag:ModifyFlag("DragOut", false)
					BtWbag:SetUltraTextNormal("")
				end
			else
				BtWbag:SetNormalImage(0)
				BtWbag:ModifyFlag("DragOut", false)
				BtWbag:SetUltraTextNormal("")
			end

			if bOutOfDate then
				BtWbag:ModifyFlag("DragIn", false)
			else
				BtWbag:ModifyFlag("DragIn", true)
			end

			if BtWbag:IsHovered() then
				layWorld_frmWarebagEx_BtWbag_OnHint(BtWbag)
			end
		end
	end

end


function layWorld_frmWarebagEx_Show(number)
	UI_Bank_Ware_Bag_Current_Open = number
	local self = uiGetglobal("layWorld.frmWarebagEx")
	self:ShowAndFocus()
	layWorld_frmWarebagEx_Refresh()

end

function layWorld_frmWarebagEx_Hide()
	local frmWarebagEx = uiGetglobal("layWorld.frmWarebagEx")
	frmWarebagEx:Hide()
end

function layWorld_frmWarebagEx_BtWbag_OnHint(self)
	local frmWarebagEx = uiGetglobal("layWorld.frmWarebagEx")
	local _, line, col = uiBank_GetUltraBagMaxCountLineCol()
	for i=1, line, 1 do
		for j=1, col, 1 do
			local BtWbag = SAPI.GetChild(frmWarebagEx, "BtWbag"..((i - 1)*col + j))
			if SAPI.Equal(self, BtWbag) then
				local _, _, _,richText = uiBank_GetBankUltraItemInfoByLineCol(UI_Bank_Ware_Bag_Current_Open, i, j)
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

function layWorld_frmWarebagEx_BtWbag_OnRClick(self)
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

function layWorld_frmWarebagEx_BtWbag_OnDragIn(self, drag)
	if UI_Bank_Npc_Object_Id == 0 or UI_Bank_Npc_Object_Id == nil then
		return
	end

	local frmWarebagEx = uiGetglobal("layWorld.frmWarebagEx")
	local wDrag = uiGetglobal(drag)

	if wDrag:Get(EV_UI_SHORTCUT_TYPE_KEY) ~= EV_SHORTCUT_OBJECT_ITEM then
		return
	end

	local itemOid = wDrag:Get(EV_UI_SHORTCUT_OBJECTID_KEY)
	if itemOid == nil then
		return
	end

	local _, line, col = uiBank_GetUltraBagMaxCountLineCol()
	for i=1, line, 1 do
		for j=1, col, 1 do
			local BtWbag = SAPI.GetChild(frmWarebagEx, "BtWbag"..((i - 1)*col + j))
			if SAPI.Equal(self, BtWbag) then
				uiBank_ItemPutInUltraBank(itemOid,UI_Bank_Ware_Bag_Current_Open, i, j, UI_Bank_Npc_Object_Id)
				return
			end
		end

	end
end

function layWorld_frmWarebagEx_OnHide()
	local frmWarehouseEx = uiGetglobal("layWorld.frmWarehouseEx")
	if UI_Bank_Ware_Bag_Current_Open > uiBank_GetUltraBagCount() then
		return
	end

	if UI_Bank_Ware_Bag_Current_Open < 1 then
		return
	end
	local BtBag = SAPI.GetChild(frmWarehouseEx, "BtBag"..UI_Bank_Ware_Bag_Current_Open)
	BtBag:SetChecked(false)
end