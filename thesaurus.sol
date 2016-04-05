import 'common.sol';

/*
 * Knowledge is a generic declaration of object or process
 */
contract Knowledge is Mortal {
    /* Knowledge can have a type described below */
    int8 constant OBJECT  = 1;
    int8 constant PROCESS = 2;

    /* Knowledge type is a int value */
    int public knowledgeType;

    function Knowledge(int8 _type) {
        knowledgeType = _type;
    }

    /* Generic Knowledge comparation procedure */
    function isEqual(Knowledge _to) constant returns (bool) {
        // Knowledge with different types can't be equal
        if (_to.knowledgeType() != knowledgeType)
            return false;
        /*
         * Knowledge with the same type can be compared,
         * comparation procedure implemented in the inherit types
         */
        if (knowledgeType == OBJECT) {
            return KObject(this).isEqualObject(KObject(_to));
        } else {
            return KProcess(this).isEqualProcess(KProcess(_to));
        }
    }
}

/*
 * The knowledge object represents the real world object
 * that can be consist of some another objects and have
 * a count of attributes
 */
contract KObject is Knowledge {
    /* Object constructor */
    function KObject() Knowledge(OBJECT) {}

    /* List of object property names */
    string[] public properties;

    function propertiesLength() constant returns (uint)
    { return properties.length; }

    /* Hash name to value mapping */
    mapping (bytes32 => string)  public propertyValueOf;
    /* Hash name to value hash mapping */
    mapping (bytes32 => bytes32) public propertyHashOf;

    /* Insert new property value by name
     *   If the same name exist value will be replaced
     */
    function insertProperty(string _name, string _value) onlyOwner {
        var nameHash = sha3(_name);
        // Check for inserting new property
        if (propertyHashOf[nameHash] == 0)
            properties[properties.length++] = _name;

        // Store property value and value hash for future comparation
        propertyValueOf[nameHash] = _value;
        propertyHashOf[nameHash]  = sha3(_value);
    }

    /* Described object can be consist of some another objects */
    Array.Data components;

    function componentsLength() constant returns (uint)
    { return Array.size(components); }

    function appendComponent(KObject _component) onlyOwner {
        Array.append(components, _component);
    }
    
    function getComponent(uint _index) constant returns (KObject) {
        return KObject(Array.get(components, _index));
    }

    /*
     * Comparation function over knowledge objects describe equal object,
     * the equal objects has:
     *  - equal properties
     *  - equal components
     */
    function isEqualObject(KObject _to) constant returns (bool) {
        return isEqualProperties(_to) && isEqualComponents(_to);
    }

    function isEqualProperties(KObject _to) constant returns (bool) {
        // Count of properties in equal objects should be same
        if (properties.length != _to.propertiesLength())
            return false;

        // Compare every property of objects
        for (uint i = 0; i < properties.length; ++i) {
            // Take a name of current property
            var nameHash = sha3(properties[i]);

            // Compare value of the same properties
            if (propertyHashOf[nameHash] != _to.propertyHashOf(nameHash))
                return false;
        }
        return true;
    }

    function isEqualComponents(KObject _to) constant returns (bool) {
        // Count of components in equal objects should be same
        if (componentsLength() != _to.componentsLength())
            return false;

        // Compare every components of objects
        for (uint i = 0; i < componentsLength(); ++i) {
            var equalFound = false;

            for (uint j = 0; j < componentsLength(); ++j)
                if (getComponent(i).isEqual(_to.getComponent(j))) {
                    equalFound = true;
                    break;
                }

            // Return false if no equal component found
            if (!equalFound)
                return false;
        }
        return true;
    }
}

/*
 * The knowledge process describe knowledge manipulation
 */
contract KProcess is Knowledge {
    /* Process constructor */
    function KProcess() Knowledge(PROCESS) {}

    /*
     * Morphism describe knowledge manipulation line
     * e.g. apple production have a morphism with 
     * three objects: Ground -> AppleTree -> Apple
     * this knowledges can be stored in morphism list
     * as [ Ground, AppleTree, Apple ]
     */
    Array.Data morphism;

    function morphismLength() constant returns (uint)
    { return Array.size(morphism); }

    /* Append knowledge into line */
    function append(Knowledge _knowledge) onlyOwner {
        Array.append(morphism, _knowledge);
    }
    
    /* Insert knowledge into position */
    function insert(Knowledge _knowledge, uint _position) {
        Array.insert(morphism, _position, _knowledge);
    }
    
    /* Get knowledge by index in line */
    function get(uint _index) constant returns (Knowledge) {
        return Knowledge(Array.get(morphism, _index));
    }

    function isEqualProcess(KProcess _to) constant returns (bool) {
        // Count of knowledges in equal processes should be same
        if (morphismLength() != _to.morphismLength())
            return false;

        for (uint i = 0; i < morphismLength(); i += 1)
            // All knowledge in morphism line should be equal
            if (!get(i).isEqual(_to.get(i)))
                return false;
        return true;
    }
}

library Thesaurus {
    struct Index {
        /* Available knowledge names */
        string [] thesaurus;

        /* Mapping to knowledge from name */
        mapping (bytes32 => Knowledge) knowledgeOf;
    }

    /*
     * Insert knowledge by name
     *   knowledge instance with the same name will be replaced
     */
    function set(Index storage _ix, string _name, Knowledge _knowledge)
            returns (Knowledge) {
        // Check for term is exist
        var nameHash = sha3(_name);
        var replaced = _ix.knowledgeOf[nameHash];
        if (replaced == Knowledge(0x0))
            _ix.thesaurus[_ix.thesaurus.length++] = _name;
        _ix.knowledgeOf[nameHash] = _knowledge;
        return replaced;
    }
    
    function get(Index storage _ix, string _name) constant returns (Knowledge) {
        return _ix.knowledgeOf[sha3(_name)];
    }
}
