/* eslint-disable no-unused-vars */
import { createElement } from 'lwc';
import ProductViewer from 'c/productViewer';
import getProducts from '@salesforce/apex/DummyJsonService.getProductsFromSF';


// Mock Apex calls
jest.mock(
    '@salesforce/apex/DummyJsonService.getProductsFromSF',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

describe('c-product-viewer', () => {
        // Helper function moved inside describe block
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    function nextTick() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        return new Promise(resolve => setTimeout(resolve, 0));
    }

    it('should show loading spinner when data is loading', async () => {
        // 1. Set up never-resolving promise
        getProducts.mockImplementation(() => new Promise(() => {}));
        
        // 2. Create and attach component
        const element = createElement('c-product-viewer', { is: ProductViewer });
        document.body.appendChild(element);
        
        // 3. Wait for component to render
        await nextTick();
        await nextTick(); // Double tick for safety
        
        // 4. Debug the DOM if needed
        
        // 5. Find spinner using test ID
        const spinner = element.shadowRoot.querySelector('[data-testid="loading-spinner"]');
        console.log('Spinner:', spinner);
        // 6. Verify spinner exists and has correct attributes
        expect(spinner).not.toBeNull();
        expect(spinner.alternativeText).toBe('Loading');
        expect(spinner.size).toBe('medium');
    });

});