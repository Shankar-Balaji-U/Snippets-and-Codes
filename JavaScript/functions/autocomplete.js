
/*
This is a JavaScript class named AutoCompleteSearchInput that provides autocomplete functionality for search input elements. The class takes in three arguments: inputElement (the search input element), searchList (an array of items to be searched), and options (an optional object containing configuration options).

The class creates a dropdown menu element (ul) to display filtered results based on user input. The dropdown menu is dynamically populated with list items (li) based on the search results. The user can select an item from the dropdown menu by clicking or using arrow keys to navigate and pressing the Enter key to confirm their selection.

The class also provides methods for filtering the searchList array, updating the selected list item, inserting the selected value into the search input, and cleaning up the dropdown menu.

Some of the important methods in the class are:

filter: This method filters the searchList array based on the user input and returns an array of matching items.
handleInput: This method is called whenever the user types into the search input. It updates the dropdown menu based on the filtered search results and highlights the matching text within the list items.
handleKeydown: This method is called whenever the user presses a key while focused on the search input. It handles arrow key navigation within the dropdown menu and selection of the currently highlighted list item.
insertSelection: This method inserts the selected value into the search input (while UP and DOWN scrolling using arrow keys) based on the currently selected index in the dropdown menu.
pushValue: This method updates the search input with the selected value and hides the dropdown menu.
*/


class AutoCompleteSearchInput {
	constructor(inputElement, searchList, options) {
		const defaults = {
			listContainerCssClass: "list-group",
			listCssClass: "list-item",
		}

		this.options = Object.assign({}, defaults, options);

		this.prefix = "autocomplete";
		if (typeof inputElement !== 'object' || inputElement === 'string' || typeof inputElement === null) {
			throw new Error('Invalid element value. The args[0] should be a HTMLDocument element.');
		}
		// Initializing the main element and the aray to be searched
		this.inputElement = inputElement;
		this.searchList = searchList;
    	this.selectedIndex = -1;

    	// this.queryset = null;  // not necessery

		this.inputElement.addEventListener("input", this.handleInput.bind(this));
		this.inputElement.addEventListener("keydown", this.handleKeydown.bind(this));
		this._createMenu()
	}

	filter(array, regexStr) {
		// filter the options based on the input value
		const items = array.filter(item => {
			var item = item.toLowerCase();

			// if the item is start with the value then it will return true.
			return item.startsWith(regexStr.toLowerCase()) // boolean value
		});
		return items;
	}

	handleInput(event) {
		// This function will works while typing inside the search element.
    	// clear the dropdown before populating with new items
    	this.dropdownElement.innerHTML = '';

		// filter the options based on the input value
		const searchItems = this.filter(this.searchList, this.inputElement.value);

		// create a list item for each filtered value and append to the dropdown
    	searchItems.forEach((value, index) => {
      		const itemElement = document.createElement('li');
        	itemElement.setAttribute("class", this.options.listCssClass);

        	// To highlight the filtered list with inputElement value
        	let highlightedText = value.replace(new RegExp(this.inputElement.value, "i"), "<strong>$&</strong>");

            // Adding the value to list tag and attrb value as the original list item value 
      		itemElement.innerHTML = highlightedText;
      		itemElement.dataset.value = value;
      		itemElement.dataset.index = index;
      		this.dropdownElement.appendChild(itemElement);

      		itemElement.addEventListener("mousedown", event => {
				this.selectedIndex = parseInt(event.target.dataset.index);
          		this.insertSelection();
				this.updateSelectedListItem();
      		});
      		itemElement.addEventListener("dblclick", event => {
				this.pushValue();
      		});
    	});
    
    	// display the dropdown if there are filtered options
    	if (searchItems.length > 0) {
    		this.dropdownElement.style.display = 'block';
    		this.queryset = searchItems;

    	} else {
    		this.dropdownElement.style.display = 'none';
    	}
    
    	// reset the selected index
    	this.selectedIndex = -1;
	}

	handleKeydown(event) {
		// For selecting and inserting the option value in the list, when arrow are pressed while inside the search element.
    	switch(event.key) {
      		case 'ArrowUp':
	        	event.preventDefault(); // prevent default arrow key behavior
	        	if (this.selectedIndex > 0) {
	          		this.selectedIndex--;
	          		this.insertSelection();
	          		this.updateSelectedListItem();
	        	}
	        	break;
      		case 'ArrowDown':
				event.preventDefault(); // prevent default arrow key behavior
				if (this.selectedIndex < this.dropdownElement.children.length - 1) {
					this.selectedIndex++;
	          		this.insertSelection();
					this.updateSelectedListItem();
				}
				break;
			case 'Enter':
				event.preventDefault(); // prevent default form submission
				this.pushValue();
				break;
      		case 'Escape':
      			// this.inputElement.blur();
      			this._cleanMenu();

        		break;
    	}
  	}

	insertSelection() {
		// insert the input value based on the selected index
		if (this.selectedIndex > -1) {
			this.inputElement.value = this.queryset[this.selectedIndex];
		} else {
			this.inputElement.value = '';
		}
	}

	updateSelectedListItem() {
		// update the selected list item based on the selected index
		Array.from(this.dropdownElement.children).forEach((itemElement, index) => {
			if (index === this.selectedIndex) {
				itemElement.classList.add('active');
			} else {
				itemElement.classList.remove('active');
			}
		});
	}

	pushValue() {
		if (this.selectedIndex > -1) {
			this.inputElement.value = this.queryset[this.selectedIndex];
			this.dropdownElement.style.display = 'none';
			this.selectedIndex = -1;
		}
	}

	_createMenu() {
		// Dropdown menu wrapper
        const menuWrapper = document.createElement("div");
        menuWrapper.setAttribute("class", "autocomplete-menuwrapper");
		menuWrapper.setAttribute("id", `${this.prefix}-menuwrapper`);

		// Add the new wrapper element after the input element
		this.inputElement.insertAdjacentElement("afterend", menuWrapper);

		// Dorpdown menu UL element
        const menu = document.createElement("ul");
        menu.setAttribute("class", "autocomplete-list " + this.options.listContainerCssClass);
        menu.setAttribute("id", this.prefix + "-list");
		menuWrapper.append(menu);
		this.dropdownElement = menu;
	}

	_cleanMenu() {
        document.getElementById(this.prefix + "-list").innerHTML = "";
	}
}
