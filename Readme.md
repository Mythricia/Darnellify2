# Darnellify2

> Avael @ Argent-Dawn EU   
> Avael#2276 @ Battle.Net EU   

-----

Spiritual successor to the original Darnellify made by Maziel:
https://www.wowinterface.com/downloads/info21093-Darnellify.html

-----

Roadmap (TBD):  
- [x] Simultaneous Modern & Classic compatibility
- [x] Easily extendable sound list in separate file
- [x] Sounds split into sensible categories
- [ ] Separate config profiles for world/dungeon/raid environments that apply automatically
- [x] Spam prevention (cooldowns)
- [x] Configurable per-sound attributes (delay, cooldown)
  - (only **Cooldown** working for now, delay to be added later)
- [ ] In-game options GUI to enable/disable sounds
- [x] Error logging during alpha/beta

Optional Extras:  
- [ ] Queue functionality to queue up sounds that trigger in quick overlapping succession?
- [ ] Chain effects? I.e. if triggered several times in a row, start playing a different set of sounds until cooldown period is over ("Stop clicking me!)

-----

All sound clips belong to MikeB:
https://twitter.com/akamikeb
https://twitch.tv/akamikeb

-----



# Changelog
## [0.10.0] - 2019-06-19
### Changed
- Big change: Addon is now split off into several smaller files.
- ToC load order is important now, as different modules depend on eachother
- No big functional changes otherwise

## [0.9.1] - 2019-06-18
### Added
- Comprehensive Lua error and custom warning logging added. See `/darn`
- play___FromCollection() now takes an optional 2nd param: a tag to idenfity the event calling it
### Changed
- Somewhat significant reworks of logMessage, and /darn messages

## [0.9.0] - 2019-06-18
### Added
- "Sounds" folder is now in the repository in its entirety
- Environmental death samples added
- UI_INFO_MESSAGE events added
- UI_ERROR_MESSAGE events added
- Interface samples and events all added
- Some basic documentation added to SampleLibrary.lua
- Basic error logging capabilities
### Changed
- "Ding!" is back in the Combat\Crit collection
- event(self) no longer passed to handlers
- Many debug print improvements and changes and removals
- library.mounts table was flattened and is now 1 level shallower

## [0.5.3] - 2019-06-16
### Changed
- A whole lot of restructuring of the internal workings. More close to final now.
- The sound library structure is now different and hopefully a lot more readable.
### Added
- Mount-up and Dismount should be fully working.
  + Mount categories and spellID's can be added freely without touching main code.

## [0.5.1] - 2019-06-14
### Changed
- Updated and renamed Readme for GitHub

## [0.5.0] - 2019-06-14
### Added
- Bare-bones working version of the addon
- Only one voice sample added for now (opening mailbox), for testing
- Next up is to add all the original events and samples.


## [0.1.0] - 2019-06-11
### Added
- Initial setup!
