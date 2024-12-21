const createElement = (name, attr = {}) => {
    const element = document.createElement(name);

    Object.entries(attr).forEach(([key, value]) => {
        switch (key) {
            case 'children':
                element.append(...value);
                break;
            case 'text':
                if (/&(?:[a-zA-Z]+|#[0-9]+|#x[0-9a-fA-F]+);/g.test(value)) {
                    element.innerHTML = value;
                } else {
                    element.textContent = value;
                }
                break;
            case 'html':
                element.innerHTML = value;
                break;
            case 'class':
                element.className = value;
                break;
            case 'dataset':
                Object.entries(value).forEach(([dataKey, dataValue]) => {
                    element.dataset[dataKey] = dataValue;
                });
                break;
            default:
                element.setAttribute(key, value);
        }
    });

    return element;
};
