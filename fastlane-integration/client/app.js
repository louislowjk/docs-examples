// instantiates the Fastlane module
const fastlane = await window.paypal.Fastlane({
    // For more details about available options parameters, see the Reference section.
});
// sets the SDK to run in sandbox mode
window.localStorage.setItem("fastlaneEnv", "sandbox");
// Specifying the locale if necessary
fastlane.setLocale('en_us');