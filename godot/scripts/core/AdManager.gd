extends Node

## Rewarded-ad bridge built on the Poing Studios AdMob plugin (v4.1.0 backend
## + v4.3.1 frontend) sitting under res://addons/admob/.
##
## External contract (unchanged from the placeholder version — GameRoot and UI
## still talk to AdManager through these signals/methods only):
##   - is_supported()        — true once the plugin loaded and the SDK initialized
##   - is_rewarded_ready()   — call before showing a CTA button
##   - show_rewarded(tag)    — opens the ad; tag is just a label for the signal
##   - rewarded_granted(tag) — fires when the user finishes the ad and earns the reward
##   - rewarded_dismissed(tag) — fires when the user closes before the reward
##   - rewarded_failed(tag, reason) — fires on load/show error
##
## ENABLED gates everything. While ENABLED=true with the Google test ad-unit
## ID below, the plugin serves test ads only — this is the configuration we
## ship to the closed-testing track until the real AdMob IDs are issued.
## See docs/ADMOB_SETUP.md for the swap procedure.

signal rewarded_granted(tag: String)
signal rewarded_dismissed(tag: String)
signal rewarded_failed(tag: String, reason: String)

# Turn this off if you need to roll back to ad-free builds without removing the
# plugin. Production builds with real IDs keep this true.
const ENABLED: bool = true

# Google's official Rewarded test unit ID — safe to call repeatedly, never
# generates revenue, and avoids the policy violation that comes with hitting
# real units during development. Replace with the real
# ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ when AdMob issues it.
const REWARDED_UNIT_ID: String = "ca-app-pub-3940256099942544/5224354917"

const REWARD_TAG_REVIVE: String = "revive"
const REWARD_TAG_DOUBLE_GOLD: String = "double_gold"

# Re-load throttle so a flaky network doesn't pin the SDK to a tight reload loop.
const _RELOAD_RETRY_DELAY_SEC: float = 30.0

var _initialized: bool = false
var _loader: RewardedAdLoader = null
var _rewarded_ad: RewardedAd = null
var _pending_tag: String = ""
var _reward_granted_in_current_show: bool = false

func _ready() -> void:
	if not ENABLED:
		return
	if OS.get_name() != "Android":
		# Plugin's GDScript classes still load on desktop, but the native
		# singleton is Android-only — skip initialization to avoid noisy
		# warnings during local editor runs.
		return
	MobileAds.initialize(_make_init_listener())

func _make_init_listener() -> OnInitializationCompleteListener:
	var listener := OnInitializationCompleteListener.new()
	listener.on_initialization_complete = func(_status: InitializationStatus) -> void:
		_initialized = true
		_load_rewarded_ad()
	return listener

func _load_rewarded_ad() -> void:
	if not _initialized:
		return
	_loader = RewardedAdLoader.new()
	var callback := RewardedAdLoadCallback.new()
	callback.on_ad_loaded = func(ad: RewardedAd) -> void:
		_rewarded_ad = ad
		_wire_full_screen_callbacks(ad)
	callback.on_ad_failed_to_load = func(error: LoadAdError) -> void:
		_rewarded_ad = null
		# Keep the SDK alive but stop retrying immediately — a fill miss often
		# means the network is bad or AdMob has no inventory; we'll try again
		# the next time the user reaches a state that wants an ad, or after
		# the throttle expires.
		var msg := error.message if error else "load_failed"
		print("[AdManager] rewarded ad failed to load: %s" % msg)
		get_tree().create_timer(_RELOAD_RETRY_DELAY_SEC).timeout.connect(_load_rewarded_ad)
	_loader.load(REWARDED_UNIT_ID, AdRequest.new(), callback)

func _wire_full_screen_callbacks(ad: RewardedAd) -> void:
	ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		var tag := _pending_tag
		_pending_tag = ""
		# If the user earned the reward, granted was already emitted from the
		# OnUserEarnedRewardListener — only emit dismissed when the user bailed.
		if not _reward_granted_in_current_show:
			rewarded_dismissed.emit(tag)
		_reward_granted_in_current_show = false
		_rewarded_ad = null
		_load_rewarded_ad()
	ad.full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(error: AdError) -> void:
		var tag := _pending_tag
		_pending_tag = ""
		_reward_granted_in_current_show = false
		_rewarded_ad = null
		var msg := error.message if error else "show_failed"
		rewarded_failed.emit(tag, msg)
		_load_rewarded_ad()

func is_supported() -> bool:
	return ENABLED and _initialized

func is_rewarded_ready() -> bool:
	return is_supported() and _rewarded_ad != null

func show_rewarded(tag: String) -> void:
	if not is_rewarded_ready():
		rewarded_failed.emit(tag, "not_ready")
		return
	_pending_tag = tag
	_reward_granted_in_current_show = false
	var listener := OnUserEarnedRewardListener.new()
	listener.on_user_earned_reward = func(_item: RewardedItem) -> void:
		_reward_granted_in_current_show = true
		rewarded_granted.emit(_pending_tag)
	_rewarded_ad.show(listener)
