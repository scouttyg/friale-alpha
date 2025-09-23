// Import the id-verifier library
import {
    createCredentialsRequest,
    generateNonce,
    generateJWK,
    requestCredentials,
    processCredentials,
    Claim,
    DocumentType,
    setTestDataUsage
} from './digital_credentials/id-verifier';

class DigitalCredentialsPage {
    constructor() {
        this.statusEl = null;
        this.requestBtn = null;
        this.resultEl = null;

        this.setup();
    }

    setup() {
        this.statusEl = document.getElementById('status');
        this.requestBtn = document.getElementById('requestBtn');
        this.resultEl = document.getElementById('result');

        this.checkCompatibility();
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Add event listeners to buttons
        if (this.requestBtn) {
            this.requestBtn.addEventListener('click', () => this.requestCredentials());
        }

        // Add event listeners to checkboxes for live sample script updates
        this.setupCheckboxListeners();
    }

    setupCheckboxListeners() {
        // Get all checkboxes in the configuration section
        const checkboxes = document.querySelectorAll('input[type="checkbox"]');

        // Add change event listener to each checkbox
        checkboxes.forEach(checkbox => {
            checkbox.addEventListener('change', () => {
                if (checkbox.id === 'useTestData') setTestDataUsage(checkbox.checked);
                this.updateSampleScript();
                this.updateCategoryButtons();
            });
        });

        // Initial update
        this.updateSampleScript();
        this.updateCategoryButtons();
    }

    /**
     * Update the text of category buttons based on current selection state
     */
    updateCategoryButtons() {
        const categories = {
            personal: [
                'givenName', 'familyName', 'birthDate', 'birthYear', 'age', 
                'ageOver18', 'ageOver21', 'sex', 'height', 'weight', 
                'eyeColor', 'hairColor', 'nationality', 'placeOfBirth'
            ],
            address: [
                'address', 'city', 'state', 'postalCode', 'country'
            ],
            document: [
                'documentNumber', 'issuingAuthority', 'issuingCountry', 'issuingJurisdiction',
                'issueDate', 'expiryDate', 'drivingPrivileges', 'portrait', 'signature'
            ]
        };

        Object.keys(categories).forEach(category => {
            const checkboxNames = categories[category];
            const checkboxes = checkboxNames.map(name => 
                document.querySelector(`input[name="${name}"]`)
            ).filter(checkbox => checkbox !== null);

            if (checkboxes.length === 0) return;

            const allSelected = checkboxes.every(checkbox => checkbox.checked);
            const button = document.querySelector(`button[onclick="toggleCategorySelection('${category}')"]`);
            
            if (button) {
                button.textContent = allSelected ? 'Deselect All' : 'Select All';
            }
        });
    }

    /**
     * Read the user's document type configuration from the checkboxes
     * @returns {Array<string>} Array of selected document type values
     */
    getDocumentTypeConfiguration() {
        const selectedDocumentTypes = [];

        // Map of checkbox names to DocumentType values
        const documentTypeMapping = {
            'mobileDriversLicense': DocumentType.MOBILE_DRIVERS_LICENSE,
            'photoId': DocumentType.PHOTO_ID,
            'euPersonalId': DocumentType.EU_PERSONAL_ID,
            'japanMyNumberCard': DocumentType.JAPAN_MY_NUMBER_CARD
        };

        // Check each document type checkbox
        for (const [checkboxName, documentTypeValue] of Object.entries(documentTypeMapping)) {
            const checkbox = document.querySelector(`input[name="${checkboxName}"]`);
            if (checkbox && checkbox.checked) {
                selectedDocumentTypes.push(documentTypeValue);
            }
        }

        return selectedDocumentTypes;
    }

    /**
     * Read the user's claim configuration from the checkboxes
     * @returns {Array<string>} Array of selected claim values
     */
    getClaimConfiguration() {
        const selectedClaims = [];

        // Map of checkbox names to Claim values
        const claimMapping = {
            'givenName': Claim.GIVEN_NAME,
            'familyName': Claim.FAMILY_NAME,
            'birthDate': Claim.BIRTH_DATE,
            'birthYear': Claim.BIRTH_YEAR,
            'age': Claim.AGE,
            'ageOver18': Claim.AGE_OVER_18,
            'ageOver21': Claim.AGE_OVER_21,
            'sex': Claim.SEX,
            'height': Claim.HEIGHT,
            'weight': Claim.WEIGHT,
            'eyeColor': Claim.EYE_COLOR,
            'hairColor': Claim.HAIR_COLOR,
            'address': Claim.ADDRESS,
            'city': Claim.CITY,
            'state': Claim.STATE,
            'postalCode': Claim.POSTAL_CODE,
            'country': Claim.COUNTRY,
            'nationality': Claim.NATIONALITY,
            'placeOfBirth': Claim.PLACE_OF_BIRTH,
            'documentNumber': Claim.DOCUMENT_NUMBER,
            'issuingAuthority': Claim.ISSUING_AUTHORITY,
            'issuingCountry': Claim.ISSUING_COUNTRY,
            'issuingJurisdiction': Claim.ISSUING_JURISDICTION,
            'issueDate': Claim.ISSUE_DATE,
            'expiryDate': Claim.EXPIRY_DATE,
            'drivingPrivileges': Claim.DRIVING_PRIVILEGES,
            'portrait': Claim.PORTRAIT,
            'signature': Claim.SIGNATURE
        };

        // Check each claim checkbox
        for (const [checkboxName, claimValue] of Object.entries(claimMapping)) {
            const checkbox = document.querySelector(`input[name="${checkboxName}"]`);
            if (checkbox && checkbox.checked) {
                selectedClaims.push(claimValue);
            }
        }

        return selectedClaims;
    }

    updateSampleScript() {
        const claimsListElement = document.getElementById('claimsList');
        const documentTypesListElement = document.getElementById('documentTypesList');

        if (!claimsListElement || !documentTypesListElement) return;

        const claims = this.getClaimConfiguration();
        const documentTypes = this.getDocumentTypeConfiguration();

        if (claims.length === 0) {
            claimsListElement.textContent = '// No claims selected';
        } else {
            // Create reverse mapping from Claim values to enum names
            const claimEnumNames = {};
            for (const [enumName, enumValue] of Object.entries(Claim)) {
                claimEnumNames[enumValue] = `Claim.${enumName}`;
            }

            // Format the claims using enum format
            const formattedClaims = claims.map(claim =>
                claimEnumNames[claim] || `'${claim}'`
            ).join(', ');
            claimsListElement.textContent = formattedClaims;
        }

        if (documentTypes.length === 0) {
            documentTypesListElement.textContent = '// No document types selected';
        } else {
            // Create reverse mapping from DocumentType values to enum names
            const documentTypeEnumNames = {};
            for (const [enumName, enumValue] of Object.entries(DocumentType)) {
                documentTypeEnumNames[enumValue] = `DocumentType.${enumName}`;
            }

            // Format the document types using enum format
            const formattedDocumentTypes = documentTypes.map(docType =>
                documentTypeEnumNames[docType] || `'${docType}'`
            ).join(', ');
            documentTypesListElement.textContent = formattedDocumentTypes;
        }
    }

    checkCompatibility() {
        if (typeof navigator === 'undefined' || !navigator.credentials || typeof DigitalCredential === 'undefined') {
            this.updateStatus('❌ Digital Credentials API not found. Please try enabling the DigitalCredentials feature flag in Chrome or Safari (iOS 26+).', 'error');
            return false;
        }

        this.updateStatus('✅ Digital Credentials API found! Requests <a href="https://caniuse.com/mdn-api_digitalcredential" target="_blank" style="text-decoration: underline; color: #007bff;">might</a> work.', 'success');
        this.enableButtons();
        return true;
    }

    updateStatus(message, type = 'info') {
        if (!this.statusEl) return;

        this.statusEl.innerHTML = message;

        const classes = {
            info: 'bg-blue-50 border border-blue-200 text-blue-800 rounded-md p-4 mb-4',
            success: 'bg-green-50 border border-green-200 text-green-800 rounded-md p-4 mb-4',
            error: 'bg-red-50 border border-red-200 text-red-800 rounded-md p-4 mb-4'
        };

        this.statusEl.className = classes[type] || classes.info;
    }

    enableButtons() {
        if (this.requestBtn) this.requestBtn.disabled = false;
    }

    showResult(message, type = 'info') {
        if (!this.resultEl) return;

        this.resultEl.classList.remove('hidden');
        this.resultEl.style.display = 'block';

        // For successful responses, add a toggle button
        if (type === 'success' && message.includes('✅ Credential request successful!')) {
            const toggleId = 'responseToggle_' + Date.now();
            const contentId = 'responseContent_' + Date.now();
            
            this.resultEl.innerHTML = `
                <div class="flex justify-between items-start mb-2">
                    <span class="font-semibold">✅ Credential request successful!</span>
                    <button id="${toggleId}" class="text-xs text-green-700 hover:text-green-900 underline ml-2" onclick="toggleResponseContent('${contentId}', '${toggleId}')">Hide Response</button>
                </div>
                <div id="${contentId}" class="whitespace-pre-wrap font-mono text-sm overflow-x-auto">${message.replace('✅ Credential request successful!\n\n', '')}</div>
            `;
        } else {
            this.resultEl.textContent = message;
        }

        const classes = {
            info: 'bg-blue-50 border border-blue-200 text-blue-800 rounded-md p-4 mt-4 whitespace-pre-wrap font-mono text-sm overflow-x-auto',
            success: 'bg-green-50 border border-green-200 text-green-800 rounded-md p-4 mt-4 whitespace-pre-wrap font-mono text-sm overflow-x-auto',
            error: 'bg-red-50 border border-red-200 text-red-800 rounded-md p-4 mt-4 whitespace-pre-wrap font-mono text-sm overflow-x-auto'
        };

        this.resultEl.className = classes[type] || classes.info;
    }

    /**
     * Convert portrait byte array to displayable image
     * @param {Object} portraitData - Portrait data as byte array object
     * @returns {string|null} Data URL for the image or null if conversion fails
     */
    convertPortraitToImage(portraitData) {
        if (!portraitData || typeof portraitData !== 'object') return null;

        try {
            // Convert object with numeric keys to Uint8Array
            const keys = Object.keys(portraitData).map(Number).sort((a, b) => a - b);
            const bytes = new Uint8Array(keys.length);
            
            for (let i = 0; i < keys.length; i++) {
                bytes[i] = portraitData[keys[i]];
            }

            // Create blob and convert to data URL
            const blob = new Blob([bytes], { type: 'image/jpeg' });
            return URL.createObjectURL(blob);
        } catch (error) {
            console.error('Error converting portrait:', error);
            return null;
        }
    }

    /**
     * Format date string for display
     * @param {string} dateString - Date in various formats
     * @returns {string} Formatted date or 'N/A'
     */
    formatDate(dateString) {
        if (!dateString) return 'N/A';
        
        try {
            const date = new Date(dateString);
            if (isNaN(date.getTime())) return dateString; // Return original if not parseable
            
            return date.toLocaleDateString('en-US', {
                month: '2-digit',
                day: '2-digit', 
                year: 'numeric'
            });
        } catch (error) {
            return dateString; // Return original string if formatting fails
        }
    }

    /**
     * Display the credential data as a driver's license
     * @param {Object} credentialData - The processed credential data
     */
    displayLicense(credentialData) {
        const licenseDisplay = document.getElementById('licenseDisplay');
        if (!licenseDisplay || !credentialData?.claims) return;

        const claims = credentialData.claims;

        // Show the license display
        licenseDisplay.classList.remove('hidden');

        // Update name
        const firstName = claims.givenName || claims.given_name || '';
        const lastName = claims.familyName || claims.family_name || '';
        const fullName = [firstName, lastName].filter(n => n).join(' ') || 'N/A';
        document.getElementById('licenseName').textContent = fullName;

        // Update portrait
        const portraitImg = document.getElementById('licensePortrait');
        const portraitPlaceholder = document.getElementById('licensePortraitPlaceholder');
        
        if (claims.portrait) {
            const imageUrl = this.convertPortraitToImage(claims.portrait);
            if (imageUrl) {
                portraitImg.src = imageUrl;
                portraitImg.style.display = 'block';
                portraitPlaceholder.style.display = 'none';
            }
        }

        // Update personal information
        document.getElementById('licenseDOB').textContent = this.formatDate(claims.birthDate || claims.birth_date) || 'N/A';
        document.getElementById('licenseSex').textContent = claims.sex || 'N/A';
        document.getElementById('licenseHeight').textContent = claims.height || 'N/A';
        document.getElementById('licenseWeight').textContent = claims.weight || 'N/A';
        document.getElementById('licenseEyes').textContent = claims.eyeColor || claims.eye_color || 'N/A';
        document.getElementById('licenseHair').textContent = claims.hairColor || claims.hair_color || 'N/A';
        document.getElementById('licenseAge').textContent = claims.age || 'N/A';

        // Update address
        document.getElementById('licenseAddress').textContent = claims.address || 'N/A';
        
        const city = claims.city || '';
        const state = claims.state || '';
        const postalCode = claims.postalCode || claims.postal_code || '';
        const cityStateZip = [city, state, postalCode].filter(s => s).join(', ') || 'N/A';
        document.getElementById('licenseCityStateZip').textContent = cityStateZip;

        // Update document info
        document.getElementById('licenseNumber').textContent = claims.documentNumber || claims.document_number || 'N/A';
        document.getElementById('licenseExpiry').textContent = this.formatDate(claims.expiryDate || claims.expiry_date) || 'N/A';
        document.getElementById('licenseCountry').textContent = claims.country || claims.issuingCountry || claims.issuing_country || 'N/A';
        
        // Show the actual issuing authority (before fallback processing)
        const rawIssuingAuthority = claims.issuingAuthority || claims.issuing_authority;
        document.getElementById('licenseIssuingAuthority').textContent = rawIssuingAuthority || 'N/A';

        // Update driving privileges
        const drivingPrivileges = claims.drivingPrivileges || claims.driving_privileges;
        if (drivingPrivileges && Array.isArray(drivingPrivileges)) {
            // Handle array of objects with vehicle_category_code
            const privilegeTexts = drivingPrivileges.map(privilege => {
                if (typeof privilege === 'object' && privilege.vehicle_category_code) {
                    return `Class ${privilege.vehicle_category_code}`;
                } else if (typeof privilege === 'string') {
                    return privilege;
                } else {
                    return privilege.toString();
                }
            });
            document.getElementById('licenseDrivingPrivileges').textContent = privilegeTexts.join(', ');
        } else if (drivingPrivileges) {
            // If it's a string or other format
            document.getElementById('licenseDrivingPrivileges').textContent = drivingPrivileges.toString();
        } else {
            document.getElementById('licenseDrivingPrivileges').textContent = 'N/A';
        }

        // Update issuing state/jurisdiction with fallback logic
        let jurisdiction = claims.issuingJurisdiction || claims.issuing_jurisdiction || claims.issuingAuthority || claims.issuing_authority;
        
        // If issuing authority is "XX-XX", fall back to state
        if (jurisdiction === 'XX-XX' || !jurisdiction) {
            jurisdiction = claims.state || 'COULD NOT DETERMINE';
        }
        
        document.getElementById('licenseState').textContent = `STATE OF ${jurisdiction.toUpperCase()}`;

        // Update age verification badges
        const ageOver18Badge = document.getElementById('ageOver18Badge');
        const ageOver21Badge = document.getElementById('ageOver21Badge');
        
        if (claims.ageOver18 === true || claims.age_over_18 === true) {
            ageOver18Badge.classList.remove('hidden');
        } else {
            ageOver18Badge.classList.add('hidden');
        }
        
        if (claims.ageOver21 === true || claims.age_over_21 === true) {
            ageOver21Badge.classList.remove('hidden');
        } else {
            ageOver21Badge.classList.add('hidden');
        }
    }

    async requestCredentials() {
        this.showResult('Reading configuration and requesting credentials...', 'info');
        console.log('Reading configuration...');

        try {
            // Get the user's configuration
            const claims = this.getClaimConfiguration();
            const documentTypes = this.getDocumentTypeConfiguration();

            if (claims.length === 0) {
                throw new Error('Please select at least one claim to request');
            }

            if (documentTypes.length === 0) {
                throw new Error('Please select at least one document type');
            }

            const nonce = generateNonce();
            const jwk = await generateJWK();
            const origin = window.location.origin;

            // Create request parameters using the user's configuration
            const requestParams = createCredentialsRequest({
                documentTypes,
                claims,
                nonce,
                jwk,
            });
            console.log('Request parameters:', JSON.stringify(requestParams, null, 2));

            // Request the credential
            const credentials = await requestCredentials(requestParams);
            console.log('Credential:', credentials);

            this.showResult('✅ Credential received successfully!\n\nProcessing credential...', 'info');

            // Verify the credential
            const result = await processCredentials(credentials, { nonce, origin, jwk });
            console.log('Credential processed:', result);

            // Display the license
            this.displayLicense(result);

            const replaceKeys = ['document', 'sessionTranscript'];
            this.showResult('✅ Credential request successful!\n\n' +
                JSON.stringify(result, (key, value) => replaceKeys.includes(key) ? '...' : value, 2).replaceAll('"..."', '...'), 'success');

        } catch (error) {
            // Hide license display on error
            const licenseDisplay = document.getElementById('licenseDisplay');
            if (licenseDisplay) {
                licenseDisplay.classList.add('hidden');
            }

            let errorMessage = error.name || error.message;
            if(navigator.userAgent.includes('Safari')) {
                if(error.name === 'TypeError') {
                    errorMessage += ' (Safari currently lacks support outside of iOS 26)';
                } else if(error.name === 'NotSupportedError') {
                    errorMessage += ' (Safari currently lacks support outside of iOS 26)';
                } else if(error.name === 'UnknownError') {
                    errorMessage += ' (Safari uses this error to indicate user closed the dialog)';
                }
            }
            this.showResult('❌ Credential request failed:\n' + errorMessage, 'error');
            console.error('Credential request failed:', error);
        }
    }
}

/**
 * Toggle visibility of response content
 * @param {string} contentId - ID of the content div to toggle
 * @param {string} toggleId - ID of the toggle button
 */
window.toggleResponseContent = function(contentId, toggleId) {
    const content = document.getElementById(contentId);
    const toggle = document.getElementById(toggleId);
    
    if (!content || !toggle) return;
    
    if (content.style.display === 'none') {
        content.style.display = 'block';
        toggle.textContent = 'Hide Response';
    } else {
        content.style.display = 'none';
        toggle.textContent = 'Show Response';
    }
};

/**
 * Toggle selection of all checkboxes in a category
 * @param {string} category - Category name ('personal', 'address', or 'document')
 */
window.toggleCategorySelection = function(category) {
    // Define which checkboxes belong to each category
    const categoryCheckboxes = {
        personal: [
            'givenName', 'familyName', 'birthDate', 'birthYear', 'age', 
            'ageOver18', 'ageOver21', 'sex', 'height', 'weight', 
            'eyeColor', 'hairColor', 'nationality', 'placeOfBirth'
        ],
        address: [
            'address', 'city', 'state', 'postalCode', 'country'
        ],
        document: [
            'documentNumber', 'issuingAuthority', 'issuingCountry', 'issuingJurisdiction',
            'issueDate', 'expiryDate', 'drivingPrivileges', 'portrait', 'signature'
        ]
    };

    const checkboxNames = categoryCheckboxes[category];
    if (!checkboxNames) return;

    // Get all checkboxes in this category
    const checkboxes = checkboxNames.map(name => 
        document.querySelector(`input[name="${name}"]`)
    ).filter(checkbox => checkbox !== null);

    if (checkboxes.length === 0) return;

    // Check if all are currently selected
    const allSelected = checkboxes.every(checkbox => checkbox.checked);
    
    // Toggle: if all are selected, deselect all; otherwise, select all
    const newState = !allSelected;
    
    checkboxes.forEach(checkbox => {
        checkbox.checked = newState;
    });

    // Update the button text
    const button = event.target;
    button.textContent = newState ? 'Deselect All' : 'Select All';

    // Trigger the sample script update
    if (window.digitalCredentialsPage) {
        window.digitalCredentialsPage.updateSampleScript();
    }
};

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    window.digitalCredentialsPage = new DigitalCredentialsPage();
});