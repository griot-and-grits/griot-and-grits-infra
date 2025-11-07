# Griot and Grits Infrastructure

This repository contains the configuration for deploying Griot and Grits applications on OpenShift using GitOps practices.

## Applications

### Backend API (`applications/gng-backend/`)
FastAPI-based digital preservation system for cultural heritage artifacts.


### Frontend (`applications/gng-frontend/`)
Web interface for the Griot and Grits platform.


### Whisper API (`applications/whisper-api/`)
Speech-to-text transcription service.



## Repository Structure

`

## Contributing

1. Create a feature branch
2. Make changes to manifests
3. Test in development namespace
4. Create pull request
5. Review and merge
6. Deploy to production

## License

See LICENSE file in application repositories.

## Related Repositories

- [griot-and-grits-backend](https://github.com/griot-and-grits/griot-and-grits-backend) - Backend API source code
- [griot-and-grits-frontend](https://github.com/griot-and-grits/gng-web) - Frontend source code
