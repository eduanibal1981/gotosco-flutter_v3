import React, { useState } from 'react';
import { Search, School, ChevronRight, ChevronDown, Check, X } from 'lucide-react';

const SchoolsCoverageScreen = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedCity, setExpandedCity] = useState(null);
  
  const [cities, setCities] = useState([
    {
      id: 1,
      name: 'Sohar',
      allSchoolsSelected: false,
      schools: [
        { id: 1, name: 'Sohar High School', location: 'Kurum', selected: false },
        { id: 2, name: 'Al Batinah International School', location: 'Al Hujrah', selected: false },
        { id: 3, name: 'Indian School Sohar', location: 'Majaz', selected: false },
        { id: 4, name: 'Sohar Private School', location: 'Falaj Al Qabail', selected: false },
      ]
    },
    {
      id: 2,
      name: 'Muscat',
      allSchoolsSelected: false,
      schools: [
        { id: 5, name: 'Sultan School', location: 'Al Khuwair', selected: false },
        { id: 6, name: 'American International School', location: 'Qurum', selected: false },
        { id: 7, name: 'British School Muscat', location: 'Al Ghubrah', selected: false },
        { id: 8, name: 'Indian School Muscat', location: 'Ruwi', selected: false },
        { id: 9, name: 'Al Sahwa Schools', location: 'Al Khuwair', selected: false },
        { id: 10, name: 'Pakistan School Muscat', location: 'Muttrah', selected: false },
      ]
    },
    {
      id: 3,
      name: 'Salalah',
      allSchoolsSelected: false,
      schools: [
        { id: 11, name: 'Salalah Private School', location: 'Al Dahariz', selected: false },
        { id: 12, name: 'Indian School Salalah', location: 'Al Husn', selected: false },
        { id: 13, name: 'Dhofar International School', location: 'Taqa', selected: false },
      ]
    }
  ]);

  const toggleCity = (cityId) => {
    setExpandedCity(expandedCity === cityId ? null : cityId);
  };

  const toggleAllSchools = (cityId) => {
    setCities(cities.map(city => {
      if (city.id === cityId) {
        const newAllSchoolsSelected = !city.allSchoolsSelected;
        return {
          ...city,
          allSchoolsSelected: newAllSchoolsSelected,
          schools: city.schools.map(school => ({ ...school, selected: newAllSchoolsSelected }))
        };
      }
      return city;
    }));
  };

  const toggleSchool = (cityId, schoolId) => {
    setCities(cities.map(city => {
      if (city.id === cityId) {
        const newSchools = city.schools.map(school =>
          school.id === schoolId ? { ...school, selected: !school.selected } : school
        );
        return {
          ...city,
          schools: newSchools,
          allSchoolsSelected: newSchools.every(s => s.selected)
        };
      }
      return city;
    }));
  };

  const getTotalSelectedSchools = () => {
    return cities.reduce((total, city) => {
      return total + city.schools.filter(s => s.selected).length;
    }, 0);
  };

  const getFilteredCities = () => {
    if (!searchQuery.trim()) return cities;

    const query = searchQuery.toLowerCase();
    return cities
      .map(city => ({
        ...city,
        schools: city.schools.filter(school =>
          school.name.toLowerCase().includes(query) ||
          school.location.toLowerCase().includes(query) ||
          city.name.toLowerCase().includes(query)
        )
      }))
      .filter(city => city.schools.length > 0);
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
              <h1 className="text-xl font-semibold">Schools Coverage</h1>
              <p className="text-sm text-gray-500 mt-0.5">
                {getTotalSelectedSchools()} school{getTotalSelectedSchools() !== 1 ? 's' : ''} selected
              </p>
            </div>
          </div>

          {/* Search Bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search schools, locations, or cities..."
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
              <School className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <h3 className="font-medium text-gray-900 mb-1">
                Select School Coverage
              </h3>
              <p className="text-sm text-gray-600">
                Choose the schools where you can pick up and drop off students.
              </p>
            </div>
          </div>
        </div>

        {/* Cities List */}
        {filteredCities.length === 0 ? (
          <div className="text-center py-12">
            <School className="w-12 h-12 text-gray-300 mx-auto mb-3" />
            <p className="text-gray-500">No schools found matching "{searchQuery}"</p>
          </div>
        ) : (
          <div className="space-y-3">
            {filteredCities.map((city) => {
              const isExpanded = expandedCity === city.id;
              const selectedCount = city.schools.filter(s => s.selected).length;

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
                          {city.schools.length} school{city.schools.length !== 1 ? 's' : ''} available
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
                        {/* Select All Schools */}
                        <label className="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 cursor-pointer transition-colors border-2 border-teal-500 bg-teal-50">
                          <input
                            type="checkbox"
                            checked={city.allSchoolsSelected}
                            onChange={() => toggleAllSchools(city.id)}
                            className="w-5 h-5 text-teal-600 rounded border-gray-300 focus:ring-teal-500"
                          />
                          <div className="flex-1">
                            <span className="font-medium text-gray-900">All Schools in {city.name}</span>
                            <p className="text-xs text-gray-500 mt-0.5">Select all {city.schools.length} schools</p>
                          </div>
                        </label>

                        {/* Individual Schools */}
                        <div className="space-y-1">
                          {city.schools.map((school) => (
                            <label
                              key={school.id}
                              className="flex items-start gap-3 p-3 rounded-lg hover:bg-gray-50 cursor-pointer transition-colors"
                            >
                              <input
                                type="checkbox"
                                checked={school.selected}
                                onChange={() => toggleSchool(city.id, school.id)}
                                className="w-5 h-5 text-teal-600 rounded border-gray-300 focus:ring-teal-500 mt-0.5"
                              />
                              <div className="flex-1 min-w-0">
                                <div className="flex items-start gap-2">
                                  <School className="w-4 h-4 text-gray-400 flex-shrink-0 mt-0.5" />
                                  <div className="flex-1 min-w-0">
                                    <p className="font-medium text-gray-900 leading-snug">
                                      {school.name}
                                    </p>
                                    <p className="text-sm text-gray-500 mt-1 flex items-center gap-1">
                                      <span className="inline-block w-1 h-1 bg-gray-400 rounded-full"></span>
                                      {school.location}
                                    </p>
                                  </div>
                                </div>
                              </div>
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
            Save Schools Coverage
          </button>
        </div>
      </div>
    </div>
  );
};

export default SchoolsCoverageScreen;