-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local select = select
local unpack = unpack
local next = next

-- Locals
local FADEFRAMES, FADEMANAGER = {}, CreateFrame('FRAME')
FADEMANAGER.delay = 0

function UI:UIFrameFade_OnUpdate(elapsed)
	FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

	if (FADEMANAGER.timer > FADEMANAGER.delay) then
		FADEMANAGER.timer = 0

		for frame, info in next, FADEFRAMES do
			if (frame:IsVisible()) then
				info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.delay)
			else
				info.fadeTimer = info.timeToFade + 1
			end

			if (info.fadeTimer < info.timeToFade) then
				if (info.mode == 'IN') then
					frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
				else
					frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
				end
			else
				frame:SetAlpha(info.endAlpha)

				if (info.fadeHoldTime and info.fadeHoldTime > 0)  then
					info.fadeHoldTime = info.fadeHoldTime - elapsed
				else
					UI:UIFrameFadeRemoveFrame(frame)

					if (info.finishedFunc) then
						if (info.finishedArgs) then
							info.finishedFunc(unpack(info.finishedArgs))
						else
							info.finishedFunc(info.finishedArg1, info.finishedArg2, info.finishedArg3, info.finishedArg4, info.finishedArg5)
						end

						if (not info.finishedFuncKeep) then
							info.finishedFunc = nil
						end
					end
				end
			end
		end

		if (not next(FADEFRAMES)) then
			FADEMANAGER:SetScript('OnUpdate', nil)
		end
	end
end

function UI:UIFrameFade(frame, info)
	if (not frame or frame:IsForbidden()) then
		return
	end

	frame.fadeInfo = info

	if (not info.mode) then
		info.mode = 'IN'
	end

	if (info.mode == 'IN') then
		if (not info.startAlpha) then
			info.startAlpha = 0
		end

		if (not info.endAlpha) then
			info.endAlpha = 1
		end

		if (not info.diffAlpha) then
			info.diffAlpha = info.endAlpha - info.startAlpha
		end
	else
		if (not info.startAlpha) then
			info.startAlpha = 1
		end

		if (not info.endAlpha) then
			info.endAlpha = 0
		end

		if (not info.diffAlpha) then
			info.diffAlpha = info.startAlpha - info.endAlpha
		end
	end

	frame:SetAlpha(info.startAlpha)

	if (not frame:IsProtected()) then
		frame:Show()
	end

	if (not FADEFRAMES[frame]) then
		FADEFRAMES[frame] = info
		FADEMANAGER:SetScript('OnUpdate', UI.UIFrameFade_OnUpdate)
	else
		FADEFRAMES[frame] = info
	end
end

function UI:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	if (not frame or frame:IsForbidden()) then
		return
	end

	if (frame.FadeObject) then
		frame.FadeObject.fadeTimer = nil
	else
		frame.FadeObject = {}
	end

	frame.FadeObject.mode = 'IN'
	frame.FadeObject.timeToFade = timeToFade
	frame.FadeObject.startAlpha = startAlpha
	frame.FadeObject.endAlpha = endAlpha
	frame.FadeObject.diffAlpha = endAlpha - startAlpha

	UI:UIFrameFade(frame, frame.FadeObject)
end

function UI:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	if (not frame or frame:IsForbidden()) then
		return
	end

	if (frame.FadeObject) then
		frame.FadeObject.fadeTimer = nil
	else
		frame.FadeObject = {}
	end

	frame.FadeObject.mode = 'OUT'
	frame.FadeObject.timeToFade = timeToFade
	frame.FadeObject.startAlpha = startAlpha
	frame.FadeObject.endAlpha = endAlpha
	frame.FadeObject.diffAlpha = startAlpha - endAlpha

	UI:UIFrameFade(frame, frame.FadeObject)
end

function UI:UIFrameFadeRemoveFrame(frame)
	if (frame and FADEFRAMES[frame]) then
		if (frame.FadeObject) then
			frame.FadeObject.fadeTimer = nil
		end

		FADEFRAMES[frame] = nil
	end
end
