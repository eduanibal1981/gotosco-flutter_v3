import React, { useState } from 'react';
import { Search, MapPin, ChevronRight, ChevronDown, Check, X } from 'lucide-react';

const AreasCoverageScreen = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedCity, setExpandedCity] = useState(null);
  
  const [cities, setCities] = useState([
    {
      id: 1,
      name: 'Sohar',
      allAreasSelected: false,
      areas: [
        { id: 1, name: 'Al Hujrah', selected: false },
        { id: 2, name: 'Falaj Al Qabail', selected: false },
        { id: 3, name: 'Majaz', selected: false },
        { id: 4, name: 'Kurum', selected: false },
      ]
    },
    {
      id: 2,
      name: 'Muscat',
      allAreasSelected: false,
      areas: [
        { id: 5, name: 'Al Khuwair', selected: false },
        { id: 6, name: 'Qurum', selected: false },
        { id: 7, name: 'Al Ghubrah', selected: false },
        { id: 8, name: 'Ruwi', selected: false },
        { id: 9, name: 'Muttrah', selected: false },
      ]
    },
    {
      id: 3,
      name: 'Salalah',
      allAreasSelected: false,
      areas: [
        { id: 10, name: 'Al Dahariz', selected: false },
        { id: 11, name: 'Al Husn', selected: false },
        { id: 12, name: 'Taqa', selected: false },
      ]
    }
  ]);

  const toggleCity = (cityId) => {
    setExpandedCity(expandedCity === cityId ? null : cityId);
  };

  const toggleAllAreas = (cityId) => {
    setCities(cities.map(city => {
      if (city.id === cityId) {
        const newAllAreasSelected = !city.allAreasSelected;
        return {
          ...city,
          allAreasSelected: newAllAreasSelected,
          areas: city.areas.map(area => ({ ...area, selected: newAllAreasSelected }))
        };
      }
      return city;
    }));
  };

  const toggleArea = (cityId, areaId) => {
    setCities(cities.map(city => {
      if (city.id === cityId) {
        const newAreas = city.areas.map(area =>
          area.id === areaId ? { ...area, selected: !area.selected } : area
        );
        return {
          ...city,
          areas: newAreas,
          allAreasSelected: newAreas.every(a => a.selected)
        };
      }
      return city;
    }));
  };

  const getTotalSelectedAreas = () => {
    return cities.reduce((total, city) => {
      return total + city.areas.filter(a => a.selected).length;
    }, 0);
  };

  const getFilteredCities = () => {
    if (!searchQuery.trim()) return cities;

    return cities
      .map(city => ({
        ...city,
        areas: city.areas.filter(area =>
          area.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
          city.name.toLowerCase().includes(searchQuery.toLowerCase())
        )
      }))
      .filter(city => city.areas.length > 0);
  };

  const filteredCities = getFilteredCities();

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b sticky top-0 z-10">
        <div className="max-w-2xl mx-auto px-4 py-4">
          <div className="flex items-center gap-3 mb-4">
            <button className="p-2 hover:bg-gray-100 rounded-full">
              <X className="w-6 h-6" />
            </button>
            <div className="flex-1">
              <h1 className="text-xl font-semibold">Areas Coverage</h1>
              <p className="text-sm text-gray-500 mt-0.5">
                {getTotalSelectedAreas()} area{getTotalSelectedAreas() !== 1 ? 's' : ''} selected
              </p>
            </div>
          </div>

          {/* Search Bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search cities or areas..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
            />
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-2xl mx-auto px-4 py-6 pb-24">
        {/* Summary Card */}
        <div className="bg-teal-50 border border-teal-200 rounded-lg p-4 mb-6">
          <div className="flex items-start gap-3">
            <div className="bg-teal-500 rounded-full p-2">
              <MapPin className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <h3 className="font-medium text-gray-900 mb-1">
                Select Service Areas
              </h3>
              <p className="text-sm text-gray-600">
                Choose the neighborhoods and areas where you can provide transportation services.
              </p>
            </div>
          </div>
        </div>

        {/* Cities List */}
        {filteredCities.length === 0 ? (
          <div className="text-center py-12">
            <MapPin className="w-12 h-12 text-gray-300 mx-auto mb-3" />
            <p className="text-gray-500">No areas found matching "{searchQuery}"</p>
          </div>
        ) : (
          <div className="space-y-3">
            {filteredCities.map((city) => {
              const isExpanded = expandedCity === city.id;
              const selectedCount = city.areas.filter(a => a.selected).length;

              return (
                <div key={city.id} className="bg-white rounded-lg shadow-sm border overflow-hidden">
                  {/* City Header */}
                  <button
                    onClick={() => toggleCity(city.id)}
                    className="w-full px-4 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      {isExpanded ? (
                        <ChevronDown className="w-5 h-5 text-gray-400" />
                      ) : (
                        <ChevronRight className="w-5 h-5 text-gray-400" />
                      )}
                      <div className="text-left">
                        <h3 className="font-semibold text-gray-900">{city.name}</h3>
                        <p className="text-sm text-gray-500">
                          {city.areas.length} area{city.areas.length !== 1 ? 's' : ''} available
                        </p>
                      </div>
                    </div>
                    {selectedCount > 0 && (
                      <div className="bg-teal-500 text-white rounded-full w-8 h-8 flex items-center justify-center text-sm font-medium">
                        {selectedCount}
                      </div>
                    )}
                  </button>

                  {/* Expanded Content */}
                  {isExpanded && (
                    <div className="border-t">
                      <div className="p-4 space-y-2">
                        {/* Select All Areas */}
                        <label className="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 cursor-pointer transition-colors border-2 border-teal-500 bg-teal-50">
                          <input
                            type="checkbox"
                            checked={city.allAreasSelected}
                            onChange={() => toggleAllAreas(city.id)}
                            className="w-5 h-5 text-teal-600 rounded border-gray-300 focus:ring-teal-500"
                          />
                          <div className="flex-1">
                            <span className="font-medium text-gray-900">All Areas in {city.name}</span>
                            <p className="text-xs text-gray-500 mt-0.5">Select all {city.areas.length} areas</p>
                          </div>
                        </label>

                        {/* Individual Areas */}
                        <div className="space-y-1">
                          {city.areas.map((area) => (
                            <label
                              key={area.id}
                              className="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 cursor-pointer transition-colors"
                            >
                              <input
                                type="checkbox"
                                checked={area.selected}
                                onChange={() => toggleArea(city.id, area.id)}
                                className="w-5 h-5 text-teal-600 rounded border-gray-300 focus:ring-teal-500"
                              />
                              <MapPin className="w-4 h-4 text-gray-400" />
                              <span className="text-gray-700">{area.name}</span>
                            </label>
                          ))}
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t shadow-lg">
        <div className="max-w-2xl mx-auto px-4 py-4">
          <button className="w-full bg-teal-600 hover:bg-teal-700 text-white font-medium py-3.5 rounded-lg transition-colors">
            Save Areas Coverage
          </button>
        </div>
      </div>
    </div>
  );
};

export default AreasCoverageScreen;