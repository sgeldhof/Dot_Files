--Location: ~/.xmonad/xmonad.hs
--
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig
import XMonad.Util.Run
import System.Exit
import System.IO
import Control.Monad

main = do
	xmproc <- spawnPipe "/usr/bin/xmobar /home/how8bit/.xmobarrc"
	xmonad $ defaultConfig
		{ manageHook = composeAll
			[ manageDocks
			, (isFullscreen --> doFullFloat)
			, manageHook defaultConfig
			]
		, handleEventHook = fullscreenEventHook
		, layoutHook = avoidStruts $ layoutHook defaultConfig
		, logHook = myLogHook <+> dynamicLogWithPP xmobarPP
			{ ppOutput = hPutStrLn xmproc
			, ppTitle = xmobarColor "green" "" . shorten 70
			}
		, modMask            = mod4Mask
		, terminal           = "urxvt"
		, borderWidth        = 0 -- Disabled
		, normalBorderColor  = "#944BFF"
		, focusedBorderColor = "#C00000"
		}
		`additionalKeys`
		[ ((mod4Mask .|. shiftMask, xK_q), quitWithWarning)
		, ((0, 0x1008FF11), spawn "amixer set Master 2-")
		, ((0, 0x1008FF13), spawn "amixer set Master 2+")
		, ((0, 0x1008FF12), spawn "amixer -D pulse set Master toggle")
		]
	
quitWithWarning :: X ()
quitWithWarning = do
	let m = "quit"
	s <- dmenu [m]
	when (m == s) (io exitSuccess)

-- Needs xcompmgr to work
myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
	where fadeAmount = 0.9
