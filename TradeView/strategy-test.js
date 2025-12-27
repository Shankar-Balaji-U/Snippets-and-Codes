const camelCase = function(str) {
    const tokens = str.replaceAll('_', ' ').replaceAll('-', ' ').split(' ');
    
    // Convert first word to lowercase, capitalize subsequent words
    return tokens.filter(token => token !== '').map((token, index) => {
        if (index === 0) {
            return token.toLowerCase();  // First word all lowercase
        } else {
            return token.charAt(0).toUpperCase() + token.slice(1).toLowerCase();
        }
    }).join('');
};


class FieldWrapper extends EventTarget {
    constructor(elementSelectorStr) {
        super();

        this.element = document.querySelector(elementSelectorStr);
        const reactPropsName = this.findReactProps(this.element);
        const reactProps = this.element[reactPropsName];

        if (!reactProps) {
            throw new Error();
        }
        if (!Object.keys(this.element[reactPropsName]).includes('onChange')) {
            throw new Error();
        }

        if (!Object.keys(this.element[reactPropsName]).includes('onBlur')) {
            throw new Error();
        }

        this._OnChange = this.element[reactPropsName]['onChange'];
        this._OnBlur = this.element[reactPropsName]['onBlur'];
    }

    findReactProps(element) {
        return Object.keys(element).find((i) => i.match(/_*reactProps/));
    }

    setValue(value, delay = 1500) {
        value = String(value);
        this._OnChange({
            target: { value }
        });

        this._OnBlur(this.element);
        setTimeout(() => {
            this.dispatchEvent(new CustomEvent('change'));
        }, delay);
    }

    test(range = {from: 0, to: 10}, step = 1, delay = 1500) {
        this.stop = false;
        if (range.to < range.from) {
            console.error('Invalid range: "to" must be greater than or equal to "from"');
            return;
        }
        
         const count = Math.floor((range.to - range.from) / step) + 1;
        // Create array using Array.from()
        const values = Array.from(
            { length: count },
            (_, index) => range.from + (index * step)
        );
        
        // Process with delay
        let currentIndex = 0;
        
        const processNext = () => {
            if (this.stop || currentIndex >= values.length) {
                return;
            }
            
            const value = values[currentIndex];
            this.setValue(value);
            currentIndex++;
            
            // Continue with next value after delay
            if (currentIndex < values.length) {
                setTimeout(processNext, delay);
            }
        };
        
        // Start processing
        processNext();
    }
}
