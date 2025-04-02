import { LightningElement, wire } from 'lwc';
import getProducts from '@salesforce/apex/DummyJsonService.getProductsFromSF';
import syncProductsWithAPI from '@salesforce/apex/DummyJsonService.syncProductsWithAPI';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Constants
const MAX_PRODUCTS_PER_CATEGORY = 100;
const MAX_PRICE_PER_CATEGORY = 10000;
const DEFAULT_FILTER_VALUE = '';
const NO_BRAND_VALUE = 'NO_BRAND';

export default class ProductViewer extends LightningElement {
    products = { data: undefined, error: undefined, loading: true };
    searchTerm = '';
    selectedCategory = '';
    selectedBrand = '';
    categoryOptions = [];
    brandOptions = [];
    filteredProducts = [];

    @wire(getProducts)
    wiredProducts(result) {
        console.log('Wire result:', JSON.stringify(result));
        this.products = result;
        if (result.data) {
            console.log('Data received:', result.data.length);
            this.filteredProducts = [...result.data];
            this.setupFilters();
        }
    }

    get isLoading() {
        return this.products.loading;
    }

    get totalStock() {
        return this.filteredProducts.reduce((sum, product) => sum + (product.Stock__c || 0), 0);
    }

    get noProductsFound() {
        return !this.isLoading && (!this.filteredProducts || this.filteredProducts.length === 0);
    }

    setupFilters() {
        if (!this.products?.data) return;

        const categories = new Set();
        const brands = new Set();
        let hasNullBrand = false;

        this.products.data.forEach(product => {
            if (product.Category__c) categories.add(product.Category__c);
            if (product.Brand__c) {
                brands.add(product.Brand__c);
            } else {
                hasNullBrand = true;
            }
        });

        this.categoryOptions = this.createFilterOptions(categories, 'Categories');
        
        let brandOptions = this.createFilterOptions(brands, 'Brands');
        if (hasNullBrand) {
            brandOptions.push({ label: 'No Brand', value: NO_BRAND_VALUE });
        }
        this.brandOptions = brandOptions;
        
        this.filterProducts();
    }

    createFilterOptions(values, labelPrefix) {
        return [
            { label: `All ${labelPrefix}`, value: DEFAULT_FILTER_VALUE },
            ...Array.from(values).map(value => ({ label: value, value }))
        ];
    }

    filterProducts() {
        if (!this.products?.data) {
            this.filteredProducts = [];
            return;
        }
        
        this.filteredProducts = this.products.data.filter(product => 
            this.matchesSearch(product) && 
            this.matchesCategory(product) && 
            this.matchesBrand(product)
        );
        this.checkCategoryLimits();
    }

    matchesSearch(product) {
        return !this.searchTerm || 
            product.Name?.toLowerCase().includes(this.searchTerm.toLowerCase());
    }

    matchesCategory(product) {
        return !this.selectedCategory || product.Category__c === this.selectedCategory;
    }

    matchesBrand(product) {
        if (!this.selectedBrand) return true;
        if (this.selectedBrand === NO_BRAND_VALUE) return !product.Brand__c;
        return product.Brand__c === this.selectedBrand;
    }

    checkCategoryLimits() {
        if (!this.selectedCategory) return;

        const categoryProducts = this.filteredProducts.filter(
            p => p.Category__c === this.selectedCategory
        );

        const totalPrice = categoryProducts.reduce(
            (sum, product) => sum + (product.Price__c || 0), 0
        );

        if (categoryProducts.length > MAX_PRODUCTS_PER_CATEGORY || 
            totalPrice > MAX_PRICE_PER_CATEGORY) {
            this.showToast(
                'Limit Exceeded',
                `Category "${this.selectedCategory}" exceeds limits ` + 
                `(${MAX_PRODUCTS_PER_CATEGORY} products or $${MAX_PRICE_PER_CATEGORY} total price)`,
                'warning'
            );
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.filterProducts();
    }
    
    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.filterProducts();
    }
    
    handleBrandChange(event) {
        this.selectedBrand = event.detail.value;
        this.filterProducts();
    }

    get productsWithFormattedBrand() {
        if (!this.filteredProducts) return [];
        return this.filteredProducts.map(product => ({
          ...product,
          formattedBrand: product.Brand__c || 'Generic'
        }));
      }
    
    async handleRefresh() {
        try {
            await syncProductsWithAPI();
            await refreshApex(this.products);
            this.setupFilters();
            this.showToast('Success', 'Products refreshed from API', 'success');
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Failed to refresh products', 'error');
        }
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}