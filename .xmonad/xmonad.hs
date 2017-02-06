-- mostly copied from
-- jimr
-- http://www.haskell.org/haskellwiki/Xmonad/Config_archive/John_Goerzen%27s_Configuration
-- 
import XMonad

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog

import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace

import XMonad.Util.EZConfig
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe)

import System.IO

-- myLayout = smartBorders Full ||| tiled
--    where tiled = Tall 1 (5/100) (1/2)
main = do
    xmproc <- spawnPipe "/usr/bin/xmobar /home/sosborne/.xmobarrc"
    xmonad $ ewmh defaultConfig
        { layoutHook = avoidStruts  $  layoutHook defaultConfig
        , manageHook = manageDocks <+> manageHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 0
                        }
        , modMask = mod4Mask -- Rebind mod to super
        , terminal = "gnome-terminal"
        , borderWidth = 2
        }
        `additionalKeys`
        [ ((mod4Mask, xK_b), sendMessage ToggleStruts)
        , ((mod4Mask .|. shiftMask, xK_z), spawn "gnome-screensaver-command -l")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
        , ((shiftMask, xK_Left), spawn "amixer -D pulse sset Master 5%-")
        , ((shiftMask, xK_Right), spawn "amixer -D pulse sset Master 5%+")
        , ((shiftMask, xK_Down), spawn "amixer -D pulse sset Master toggle")  
        ]
